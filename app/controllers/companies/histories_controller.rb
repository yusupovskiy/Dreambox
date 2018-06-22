class Companies::HistoriesController < ApplicationController
  def create
    @history = History.new(params.require(:history).permit(:object_log, :object_id, :type_history, :note))
    @history.user_id = current_user.id
    subsctiption_history = Subscription.find(@history.object_id)

    respond_to do |format|
      if @history.type_history == 'recalculation'
        conversion_amount = params[:history][:conversion_amount]
        if conversion_amount != nil and @history.note != ''
          @history.note = "Сумма перерасчета #{conversion_amount} ₽ | Причина: " + @history.note
          if @history.save 
            subsctiption_history.update_attribute(:price, conversion_amount)
            format.html { redirect_to request.referer, notice: "Перерасчет на сумму #{conversion_amount} ₽ произведен" }
            format.json { render :show, status: :created, location: @history } 
          else
            format.html { redirect_to request.referer, notice: 'Внимание! Перерасчет не произведен' }
            format.json { render json: @history.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to request.referer, notice: 'Внимание! Для перерасчета необходимо заполнить все поля' }
        end
      elsif @history.type_history == 'cancel'
        if @history.object_log == 'subscription'
          if @history.note != '' 
            if Date.today <= subsctiption_history.finish_at
              @history.note = "Отмена абонемента | Причина: " + @history.note
              if subsctiption_history.is_active == true and @history.save 
                subsctiption_history.update_attribute(:is_active, false)
                format.html { redirect_to request.referer, notice: "Отмена абонемента произведена" }
                format.json { render :show, status: :created, location: @history } 
              else
                format.html { redirect_to request.referer, notice: 'Внимание! Отмена абонемента не произведена' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
              end
            else
              format.html { redirect_to request.referer, notice: 'Внимание! Нельзя отменять абонементы с истекшим сроком' }
            end
          else
            format.html { redirect_to request.referer, notice: 'Внимание! Для отмены необходимо указать причину' }
          end
        elsif @history.object_log == 'fin_operation'
          fin_operation_history = FinOperation.find(@history.object_id)
          if @history.note != ''
              @history.note = "Отмена финансовой операции | Причина: " + @history.note
              if fin_operation_history.is_active == true and @history.save
                fin_operation_history.update_attribute(:is_active, false)
                format.html { redirect_to request.referer, notice: "Отмена финансовой операции произведена" }
                format.json { render :show, status: :created, location: @history }
              else
                format.html { redirect_to request.referer, notice: 'Внимание! Отмена финансовой операции не произведена' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
              end
          else
            format.html { redirect_to request.referer, notice: 'Внимание! Для отмены необходимо указать причину' }
          end
        end
      elsif @history.type_history == 'renewal'
        if Date.today <= subsctiption_history.finish_at
          days_for_correction = params[:history][:days_for_correction].to_i
          if days_for_correction != 0 and @history.note != ''
            @history.note = "Продление абонемента с #{subsctiption_history.finish_at.strftime("%d %b %Y")} на #{days_for_correction} дня | Причина: " + @history.note
            subscriptions = Subscription.where(record_client_id: subsctiption_history.record_client_id)
            modified_date = subsctiption_history.finish_at + days_for_correction.days 
            reserved_time = subscriptions.where('
              (? between start_at and finish_at) 
              and is_active = true', modified_date).where.not(id: @history.object_id).count.zero?
            if reserved_time
              if @history.save 
                subsctiption_history.update_attribute(:finish_at, modified_date)
                format.html { redirect_to request.referer, notice: "Продление абонемента произведено" }
                format.json { render :show, status: :created, location: @history } 
              else
                format.html { redirect_to request.referer, notice: 'Внимание! Продление абонемента не произведено' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
              end
            else
                format.html { redirect_to request.referer, notice: 'Внимание! На продливаемые дни уже существует абонемент' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
            end
          else
            format.html { redirect_to request.referer, notice: 'Внимание! Для продления абонемента необходимо заполнить все поля' }
          end
        else
            format.html { redirect_to request.referer, notice: 'Внимание! Нельзя продлевать абонементы с истекшим сроком' }
        end
      end
    end
  end
end
