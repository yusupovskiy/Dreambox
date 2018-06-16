class Companies::HistoriesController < ApplicationController
  def create
    @history = History.new(params.require(:history).permit(:object_log, :object_id, :type_history, :note))
    @history.user_id = current_user.id

    respond_to do |format|
      if @history.type_history == 'recalculation'
        subsctiption_history = Subscription.find(@history.object_id)
        @subscription = Subscription.new(params.require(:history).permit(:price))
        if @subscription.price != nil and @history.note != ''
          @history.note = "Сумма перерасчета #{@subscription.price} ₽ | Причина: " + @history.note
          if @history.save 
            Subscription.find(@history.object_id).update_attribute(:price, @subscription.price)
            format.html { redirect_to request.referer, notice: "Перерасчет на сумму #{@subscription.price} ₽ произведен" }
            format.json { render :show, status: :created, location: @history } 
          else
            format.html { redirect_to request.referer, notice: 'Перерасчет не произведен' }
            format.json { render json: @history.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to request.referer, notice: 'Для перерасчета необходимо заполнить все поля' }
        end
      elsif @history.type_history == 'cancel'
        if @history.object_log == 'subscription'
          subsctiption_history = Subscription.find(@history.object_id)
          if @history.note != '' 
            if Date.today <= subsctiption_history.finish_at
              @history.note = "Отмена абонемента | Причина: " + @history.note
              if subsctiption_history.is_active == true and @history.save 
                Subscription.find(@history.object_id).update_attribute(:is_active, false)
                format.html { redirect_to request.referer, notice: "Отмена абонемента произведена" }
                format.json { render :show, status: :created, location: @history } 
              else
                format.html { redirect_to request.referer, notice: 'Отмена абонемента не произведена' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
              end
            else
              format.html { redirect_to request.referer, notice: 'Нельзя отменять абонементы с истекшим сроком' }
            end
          else
            format.html { redirect_to request.referer, notice: 'Для отмены необходимо указать причину' }
          end
        elsif @history.object_log == 'fin_operation'
          fin_operation_history = FinOperation.find(@history.object_id)
          if @history.note != ''
              @history.note = "Отмена финансовой операции | Причина: " + @history.note
              if fin_operation_history.is_active == true and @history.save
                FinOperation.find(@history.object_id).update_attribute(:is_active, false)
                format.html { redirect_to request.referer, notice: "Отмена финансовой операции произведена" }
                format.json { render :show, status: :created, location: @history }
              else
                format.html { redirect_to request.referer, notice: 'Отмена финансовой операции не произведена' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
              end
          else
            format.html { redirect_to request.referer, notice: 'Для отмены необходимо указать причину' }
          end
        end
      elsif @history.type_history == 'renewal'
        subsctiption_history = Subscription.find(@history.object_id)
        if Date.today <= subsctiption_history.finish_at
          @subscription = Subscription.new(params.require(:history).permit(:price))
          if @subscription.price != nil and @history.note != ''
            subscription = Subscription.find(@history.object_id)
            @history.note = "Продление абонемента с #{subscription.finish_at.strftime("%d %b %Y")} на #{@subscription.price.to_i} дня | Причина: " + @history.note
            subscriptions = Subscription.where(record_client_id: subscription.record_client_id)
            modified_date = Subscription.find(@history.object_id).finish_at + @subscription.price.to_i.days 
            reserved_time = subscriptions.where('
              (? between start_at and finish_at) 
              and is_active = true', modified_date).where.not(id: @history.object_id).count.zero?
            if reserved_time
              if @history.save 
                Subscription.find(@history.object_id).update_attribute(:finish_at, modified_date)
                format.html { redirect_to request.referer, notice: "Продление абонемента произведено" }
                format.json { render :show, status: :created, location: @history } 
              else
                format.html { redirect_to request.referer, notice: 'Продление абонемента не произведено' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
              end
            else
                format.html { redirect_to request.referer, notice: 'Внимание! На продливаемые дни уже существует абонемент' }
                format.json { render json: @history.errors, status: :unprocessable_entity }
            end
          else
            format.html { redirect_to request.referer, notice: 'Для продления абонемента необходимо заполнить все поля' }
          end
        else
            format.html { redirect_to request.referer, notice: 'Нельзя продлевать абонементы с истекшим сроком' }
        end
      end
    end
  end
end
