class TransactionsController < ApplicationController

  def doc_pko
    company_transactions = CompanyTransaction.where affiliate_id: @current_affiliates
    @transaction = Transaction.find_by id: params[:id], company_transaction_id: company_transactions

    if @transaction.present?
      @debt = 0
      @company_transaction = CompanyTransaction.find_by id: @transaction.company_transaction_id
      @client = Client.find_by operation_id: @company_transaction.operation_id
      
      unless @client
        @subscription = Subscription.find_by operation_id: @company_transaction.operation_id
        @reminder = Reminder.find_by operation_id: @company_transaction.operation_id
      
        payments = CompanyTransaction.find_by_sql("
          SELECT operation_id, SUM(amount) as total_payments
          FROM company_transactions 
            INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
            INNER JOIN categories ON company_transactions.category_id = categories.id
          WHERE is_active = true 
                AND budget = 'income' 
                AND operation_id = #{ @company_transaction.operation_id }
                AND date <= '#{ @transaction.date }'
          GROUP BY operation_id
        ")

        if @subscription.present?
          operation = Operation.find @company_transaction.operation_id
          @client = Client.find operation.client_id

          if payments.present?
            @debt = @subscription.price - payments.last.total_payments
          end

        elsif @reminder.present?
          @client = Client.find @reminder.client_id
          if payments.present?
            @debt = @reminder.debt - payments.last.total_payments
          end

        end

      end

      # reminder client_id

    end

    render :template => 'transactions/doc_pko',layout: false    
  end

  def get_income
    affiliates_id = @current_affiliates.ids.join(", ")

    income = CompanyTransaction.find_by_sql("
      SELECT company_transactions.*, transactions.*, categories.name, categories.budget
      FROM company_transactions 
        INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
        INNER JOIN categories ON company_transactions.category_id = categories.id
      WHERE is_active = true AND affiliate_id IN (#{affiliates_id})
             AND budget = 'income'
    ")

    respond_to do |format|
      format.json { render json: income, status: :ok }
    end
  end

  def get_expense
    
  end

  def new
    @company_transaction = CompanyTransaction.new 

    @categories = Category.where(subject: 'company').order(:created_at)
    
    @title_card = 'Добавление транзакции'
    @form_submit = 'Сохранить'

  end

  def create_transaction
    # client_operation_id = params[:client_operation_id]
    unpaid_operation_id = params[:unpaid_operation_id]
    amount = params[:amount].to_f
    # date = params[:date].nil? ? Date.today : params[:date]
    note_transaction = params[:note]
    category_id = params[:category_id]
    affiliate_id = params[:affiliate_id].to_i
    client_transactions = []

    client = Client.find_by operation_id: params[:client_operation_id]
    category = @categories_company.find_by id: category_id
    records_client = RecordClient.where client_id: client, record_id: @current_record
    subscription = Subscription.find_by operation_id: unpaid_operation_id, record_client_id: records_client
    reminder = Reminder.find_by client_id: client, operation_id: unpaid_operation_id, affiliate_id: @current_affiliates

    if amount <= 0
      complited = false
      note = 'Сумма не может быть меньше или равной нулю'

    elsif params[:date].length <= 0
      complited = false
      note = 'Нужно указать дату'

    elsif !category.present?
      complited = false
      note = 'Не указанна статья дохода или расхода'

    elsif note_transaction == ''
      complited = false
      note = 'Оставьте комментарий к транзакции'

    elsif unpaid_operation_id.present? and (!subscription.present? and !reminder.present?)
      complited = false
      note = 'У этого человека нет такой задолжности'

    elsif subscription.present? or reminder.present?
      operation_id = unpaid_operation_id

      payments = CompanyTransaction.find_by_sql("
        SELECT operation_id, SUM(amount) as total_payments
        FROM company_transactions 
          INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
          INNER JOIN categories ON company_transactions.category_id = categories.id
        WHERE is_active = true AND budget = 'income' AND operation_id = #{operation_id}
        GROUP BY operation_id
      ")

      if payments.present?
        payments = payments.last.total_payments
      else
        payments = 0
      end

      total_payments = payments + amount

      if subscription.present?
        rc = RecordClient.find(subscription.record_client_id)
        r = Record.find(rc.record_id)
        affiliate_id = r.affiliate_id

        if subscription.price < total_payments
          complited = false
          note = 'Указанная сумма больше, чем надо заплатить за абонемент'

        elsif !subscription.is_active
          complited = false
          note = 'Указанный абонемент отменен'

        else
          complited = true
          note = 'Транзакция за абонемент произведена'
        end

      elsif reminder.present?
        affiliate_id = reminder.affiliate_id

        if reminder.debt < total_payments
          complited = false
          note = 'Указанная сумма больше, чем надо заплатить'

        elsif reminder.completed
          complited = false
          note = 'Указанная задолжность уже выполнена'

        else
          complited = true
          note = 'Транзакция за задолжность произведена'
        end
      end

    elsif @current_affiliates.where(id: affiliate_id).empty?
      complited = false
      note = 'Нужно указать филиал'

    elsif client.present?
      operation_id = params[:client_operation_id]
      complited = true
      note = 'Транзакция за клиента произведена'
      
    else
      operation = Operation.create
      operation_id = operation.id

      complited = true
      note = 'Транзакция произведена'
    end

    @company_transaction = CompanyTransaction.new(affiliate_id: affiliate_id, category_id: category_id, operation_id: operation_id)
    @transaction = Transaction.new(amount: amount, date: params[:date], note: note_transaction)

    if CompanyTransaction.exists?(affiliate_id: @company_transaction.affiliate_id)
      company_transaction = CompanyTransaction.where(
                                affiliate_id: @company_transaction.affiliate_id).last
      @company_transaction.number_document = 1 + company_transaction.number_document.to_i
    else
      @company_transaction.number_document = 1
    end

    if complited == true and @transaction.save and @company_transaction.save
      @transaction.update_attribute(:company_transaction_id, @company_transaction.id)

      if reminder.present?
        operation = 'reminder'
        note = "Совершена транзакция на #{amount} ₽, номер документа #{@company_transaction.number_document}"

        if reminder.debt == total_payments
          operation = 'reminder_completed'
          reminder.update_attributes completed: true
          note = note + ". Запись была полностью оплачена и отмечена как выполнена"
        end

        log = Log.create note: note, user_id: current_user.id, type_log: 'update'
        operatin_log = OperationLog.create operation_id: reminder.operation_id, log_id: log.id

        log = OperationLog.find_by_sql("
          SELECT l.id, l.note, l.created_at, l.type_log, s.id AS user_id, s.last_name || ' ' || s.first_name AS user_name, s.avatar, ol.operation_id
          FROM operation_logs AS ol
            LEFT JOIN logs AS l
              ON ol.log_id = l.id
            LEFT JOIN users AS s
              ON l.user_id = s.id
          WHERE l.id = #{log.id}
        ").last
      end

      client_transactions = CompanyTransaction.find_by_sql("
        SELECT company_transactions.*, transactions.*, categories.name AS category_name, categories.budget
        FROM company_transactions 
          INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
          INNER JOIN categories ON company_transactions.category_id = categories.id
        WHERE company_transactions.id = #{@company_transaction.id} 
      ")
    end

    messege = {complited: complited, note: note, result: client_transactions, operation: operation, log: log}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  # def create
  #   # если есть параметр user то создавать user transaction
  #   # проверять, есть ли абонемент с таким операцией, если да, то сравнивать цену, а также, активен ли абонемент

  #   @company_transaction = CompanyTransaction.new(params.require(:company_transaction)
  #         .permit(:affiliate_id, :category_id))
  #   @transaction = Transaction.new(params.require(:company_transaction)
  #         .permit(:amount, :date, :note))

  #   if CompanyTransaction.exists?(affiliate_id: @company_transaction.affiliate_id)
  #     company_transaction = CompanyTransaction.where(
  #                               affiliate_id: @company_transaction.affiliate_id).last
  #     @company_transaction.number_document = 1 + company_transaction.number_document.to_i
  #   else
  #     @company_transaction.number_document = 1
  #   end
    
  #   operation = Operation.create
  #   @company_transaction.operation_id = operation.id

  #   respond_to do |format|
  #     if @company_transaction.save and @transaction.save
  #       @transaction.update_attribute(:company_transaction_id, @company_transaction.id)

  #       format.html { redirect_to "/transactions?transaction=#{@transaction.id}" }
  #       format.json { render :show, status: :created, location: @company_transaction }
  #     else
  #       # format.html { render :new, notice: "Действие не произведено"  }
  #       format.html { redirect_to request.referer, notice: "Действие не произведено"  }
  #       format.json { render json: @company_transaction.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def cancel_transaction 
    company_transaction_id = params[:id]
    note_cancel = params[:note]
    affiliates_id = @current_affiliates.ids.join(", ")

    transaction = CompanyTransaction.find_by_sql("
      SELECT company_transactions.id
      FROM company_transactions 
        INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
        INNER JOIN categories ON company_transactions.category_id = categories.id
        INNER JOIN operations ON company_transactions.operation_id = operations.id
      WHERE is_active = true AND transactions.id = #{company_transaction_id}
             AND affiliate_id IN (#{affiliates_id})
    ")

    if note_cancel == ''
      complited = false
      note = 'Нужно указать причину отмены в поле'

    elsif !transaction.present?
      complited = false
      note = 'Отменяемой транзакции не существует'

    else
      t = Transaction.find_by company_transaction_id: transaction
      t.update_attribute(:note, 'Причина отмены: "' + note_cancel + '" | ' + t.note)
      t.update_attribute(:is_active, false)
      complited = true
      note = 'Отмена произведена'
    end

    messege = {complited: complited, note: note}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  private
    def company_transaction_params
      # params.require(:company_transaction)
      #     .permit(:affiliate_id, :category_id,
      #           transaction_attributes: [:amount, :date, :note])
      params.require(:company_transaction)
          .permit(:affiliate_id, :category_id)
    end
end
