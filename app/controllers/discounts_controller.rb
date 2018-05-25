class DiscountsController < ApplicationController

  def create
    discount = Discount.create! discount_params

    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { render json: discount }
    end
  end

  private
    def discount_params
      params.require(:discount)
        .permit(:record_client_id, :note, :value, :start_at, :finish_at)
    end
end
