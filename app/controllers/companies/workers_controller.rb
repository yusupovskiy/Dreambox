class Companies::WorkersController < ApplicationController
  # before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  # before_action :set_s3_direct_post, only: [:new, :edit]
  
  # def index
  #   @people = Client.where(company: @current_company.id)
  #   @clients = @people.where("(role & #{Client::Role::STUFF}) != 0")

  #   @all_people = @clients
  #   @show_in_view = [@all_people]
  #   render :template => 'companies/clients/index'
  # end
  # def show

  #   render :template => 'companies/clients/show'
  # end
  # def new
  #   @client = Client.new company_id: @current_company.id, role: (Client::Role::STUFF).to_s(2).to_i
  #   render :template => 'companies/clients/new'
  # end
  # def create
  #   prms = client_params
  #   @client = Client.new(prms)

  #   email = params[:client][:email]

  #   account = User.find_by(email: email)
  #   if account.present?
  #     @client.user_id = account.id
  #   end

  #   @client.role = (Client::Role::STUFF).to_s(2).to_i


  #   respond_to do |format|
  #     if @client.save
  #       format.html { redirect_to [@client.company, @client], notice: t('client.created') }
  #       format.json { render :show, status: :created }
  #     else
  #       format.html { ensure_current_user; set_s3_direct_post; render :new } #   redirect_to request.referer
  #       format.json { render json: @client.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # private
  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def client_params
  #     res = params.require(:client)
  #       .permit(:first_name, :last_name, :patronymic, 
  #               :birthday, :phone_number, :sex, :avatar,
  #               field_data_attributes: [:id, :field_id, :value])
  #       .merge(company_id: @current_company.id)

  #     res[:avatar] = nil if params[:client][:avatar].blank?
  #     res
  #   end
  #   def set_s3_direct_post
  #     args = {
  #         key: "images/#{SecureRandom.uuid}/${filename}",
  #         success_action_status: '201',
  #         acl: 'public-read'
  #     }
  #     @s3_direct_post = S3_BUCKET.presigned_post(args)
  #   end
end
