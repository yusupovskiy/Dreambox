class DiscountsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]

  def create
    discount = Discount.new discount_params

    unless discount.value > 0
      return redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Цена не может быть равно нулю"
    end

    respond_to do |format|
      if discount.save
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet completed\" />Коррекция цены произведена" }
        format.json { render json: discount }
      end
    end
  end

  private
    def discount_params
      params.require(:discount)
        .permit(:record_client_id, :note, :value, :start_at, :finish_at)
    end
end
