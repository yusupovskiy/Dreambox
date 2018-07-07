class DiscountsController < ApplicationController
  before_action :set_people
  before_action :set_company
  before_action :set_access
  before_action :set_affiliate
  before_action :confirm_actions, only: [:create, :update, :destroy]

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
