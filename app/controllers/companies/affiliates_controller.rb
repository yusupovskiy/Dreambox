class Companies::AffiliatesController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :ensure_current_user, :ensure_company_owner_role, only: [:index, :new, :edit, :update, :destroy]
  before_action :set_affiliate, only: [:show, :new, :edit]

  # GET /affiliates
  # GET /affiliates.json
  def index
    @affiliates = Affiliate.where(company_id: @current_company.id)
    @total_affiliates = @affiliates.count
  end

  # GET /affiliates/1
  # GET /affiliates/1.json
  def show
  end

  # GET /affiliates/new
  def new
    @affiliate = Affiliate.new company_id: @current_company.id
    @title_card = 'Добавление филиала'
    @form_submit = 'Сохранить'

    if request.referrer == request.original_url or request.referrer == nil
      @url_back = clients_path
    else
      @url_back = request.referrer
    end
  end

  # GET /affiliates/1/edit
  def edit
  end

  # POST /affiliates
  # POST /affiliates.json
  def create
    @affiliate = Affiliate.new(affiliate_params)

    respond_to do |format|
      if @affiliate.save
        format.html { redirect_to clients_path, notice: t('affiliate.created') }
        format.json { render :show, status: :created, location: @affiliate }
      else
        # format.html { render :new, notice: "Действие не произведено"  }
        format.html { redirect_to request.referer, notice: "Действие не произведено"  }
        format.json { render json: @affiliate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /affiliates/1
  # PATCH/PUT /affiliates/1.json
  def update
    respond_to do |format|
      if @affiliate.update(affiliate_params)
        format.html { redirect_to @affiliate, notice: t('affiliate.updated') }
        format.json { render :show, status: :ok, location: @affiliate }
      else
        format.html { render :edit }
        format.json { render json: @affiliate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliates/1
  # DELETE /affiliates/1.json
  def destroy
    @affiliate.destroy
    respond_to do |format|
      format.html { redirect_to affiliates_url, notice: t('affiliate.destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def set_affiliate
      @current_affiliate = Affiliate.find_by company_id: @current_company
    end
    def affiliate_params
      params.require(:affiliate)
          .permit(:name, :address, :email, :phone_number)
          .merge(company_id: @current_company.id)
    end
end
