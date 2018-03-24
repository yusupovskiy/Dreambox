class CompaniesController < ApplicationController
  before_action :ensure_current_user
  before_action :ensure_company_owner, except: [:new, :create]
  before_action :set_company, only: [:edit, :update, :destroy]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.where(user: current_user)
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find(params[:id])
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    success_saving = ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless @company.save
      user = company_params[:user]
      user.role |= User::Role::COMPANY_OWNER
      user.save!
    end

    respond_to do |format|
      if success_saving
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
      if @company.user_id != current_user.id
        redirect_to companies_path, notice: 'Sorry, but that company is not yours'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name).merge(user: current_user)
    end

    def ensure_company_owner
      redirect_to action: :new if current_user.role & User::Role::COMPANY_OWNER == 0
    end
end
