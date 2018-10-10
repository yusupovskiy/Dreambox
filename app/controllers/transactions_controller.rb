class TransactionsController < ApplicationController

  def doc_pko
    company_transactions = CompanyTransaction.where affiliate_id: @current_affiliates
    @transaction = Transaction.find_by id: params[:id], company_transaction_id: company_transactions

    if @transaction.present?
      @company_transaction = CompanyTransaction.find_by id: @transaction.company_transaction_id
    end

    render :template => 'transactions/doc_pko',layout: false    
  end

  def get_client_transactions
    client_id = params[:client_id]

    if client_id.present?
      affiliates_id = @current_affiliates.ids.join(", ")

      client_transactions = CompanyTransaction.find_by_sql("
        SELECT company_transactions.*, transactions.*, categories.name AS category_name, categories.budget
        FROM company_transactions 
          INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
          INNER JOIN categories ON company_transactions.category_id = categories.id
          INNER JOIN operations ON company_transactions.operation_id = operations.id
        WHERE transactions.is_active = true AND operations.client_id = #{client_id}
               AND affiliate_id IN (#{affiliates_id})
        ORDER BY transactions.created_at DESC
      ")

      respond_to do |format|
        format.json { render json: client_transactions, status: :ok }
      end
    end
  end
  def get_transactions
    affiliates_id = @current_affiliates.ids.join(", ")

    transactions = CompanyTransaction.find_by_sql("
      SELECT company_transactions.*, transactions.*, categories.name AS category_name, categories.budget
      FROM company_transactions 
        INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
        INNER JOIN categories ON company_transactions.category_id = categories.id
        INNER JOIN operations ON company_transactions.operation_id = operations.id
      WHERE affiliate_id IN (#{affiliates_id})
      ORDER BY transactions.created_at DESC
    ")

    respond_to do |format|
      format.json { render json: transactions, status: :ok }
    end
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

  def index
  end

  def new
    @company_transaction = CompanyTransaction.new 

    @categories = Category.all
    
    @title_card = 'Добавление транзакции'
    @form_submit = 'Сохранить'

  end

  def create_transaction
    operation_id = params[:operation_id]
    amount = params[:amount].to_f
    date = params[:date].nil? ? Date.today : params[:date]
    note_transaction = params[:note]
    category_id = params[:category_id].to_i # поулчаем категорию которую выбираем при добвалении прочего
    affiliate_id = params[:affiliate_id].to_i
    client_transactions = []

    if amount <= 0
      complited = false
      note = 'Сумма не может быть меньше или равной нулю'

    elsif note_transaction == ''
      complited = false
      note = 'Оставьте комментарий к транзакции'

    elsif Subscription.exists? operation_id: operation_id

      subscription = Subscription.find_by operation_id: operation_id
      rc = RecordClient.find(subscription.record_client_id)
      r = Record.find(rc.record_id)
      affiliate_id = r.affiliate_id

      amount_subscription = CompanyTransaction.find_by_sql("
        SELECT operation_id, SUM(amount) as total_amount
        FROM company_transactions 
          INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
          INNER JOIN categories ON company_transactions.category_id = categories.id
        WHERE is_active = true AND budget = 'income' AND operation_id = #{operation_id}
        GROUP BY operation_id
      ")
      if amount_subscription.present?
        amount_subscription = amount_subscription.last.total_amount
      else
        amount_subscription = 0
      end

      total_amount = amount_subscription + amount

      if subscription.price < total_amount
        complited = false
        note = 'Указанная сумма больше, чем надо заплатить за абонемент'

      elsif !subscription.is_active
        complited = false
        note = 'Указанный абонемент отменен'

      else
        complited = true
        note = 'Транзакция за абонемент произведена'
        category_id = 2
      end

    elsif Client.exists? operation_id: operation_id

      if !(affiliate_id > 0)
        complited = false
        note = 'Не указан филиал'

      elsif !(category_id > 0)
        complited = false
        note = 'Не указанна статья дохода или расхода'

      else
        complited = true
        note = 'Транзакция за клиента произведена'
      end
      
    else
      complited = false
      note = 'Транзакция не произведена'
    end

    @company_transaction = CompanyTransaction.new(affiliate_id: affiliate_id, category_id: category_id, operation_id: operation_id)
    @transaction = Transaction.new(amount: amount, date: date, note: note_transaction)

    if CompanyTransaction.exists?(affiliate_id: @company_transaction.affiliate_id)
      company_transaction = CompanyTransaction.where(
                                affiliate_id: @company_transaction.affiliate_id).last
      @company_transaction.number_document = 1 + company_transaction.number_document.to_i
    else
      @company_transaction.number_document = 1
    end

    if complited == true and @transaction.save and @company_transaction.save
      @transaction.update_attribute(:company_transaction_id, @company_transaction.id)

      client_transactions = CompanyTransaction.find_by_sql("
        SELECT company_transactions.*, transactions.*, categories.name, categories.budget
        FROM company_transactions 
          INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
          INNER JOIN categories ON company_transactions.category_id = categories.id
        WHERE company_transactions.id = #{@company_transaction.id} 
      ")
    end

    messege = {complited: complited, note: note, result: client_transactions}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  def create
    # если есть параметр user то создавать user transaction
    # проверять, есть ли абонемент с таким операцией, если да, то сравнивать цену, а также, активен ли абонемент

    @company_transaction = CompanyTransaction.new(params.require(:company_transaction)
          .permit(:affiliate_id, :category_id))
    @transaction = Transaction.new(params.require(:company_transaction)
          .permit(:amount, :date, :note))

    if CompanyTransaction.exists?(affiliate_id: @company_transaction.affiliate_id)
      company_transaction = CompanyTransaction.where(
                                affiliate_id: @company_transaction.affiliate_id).last
      @company_transaction.number_document = 1 + company_transaction.number_document.to_i
    else
      @company_transaction.number_document = 1
    end
    
    operation = Operation.create
    @company_transaction.operation_id = operation.id

    respond_to do |format|
      if @company_transaction.save and @transaction.save
        @transaction.update_attribute(:company_transaction_id, @company_transaction.id)

        format.html { redirect_to "/transactions?transaction=#{@transaction.id}" }
        format.json { render :show, status: :created, location: @company_transaction }
      else
        # format.html { render :new, notice: "Действие не произведено"  }
        format.html { redirect_to request.referer, notice: "Действие не произведено"  }
        format.json { render json: @company_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel_transaction 
    company_transaction_id = params[:id]
    note = params[:note]
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

    if note == ''
      complited = false
      note = 'Нужно указать причину отмены в поле'

    elsif !transaction.present?
      complited = false
      note = 'Отменяемой транзакции не существует'

    else
      t = Transaction.find_by company_transaction_id: transaction
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
