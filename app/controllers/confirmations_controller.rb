class ConfirmationsController < Devise::ConfirmationsController
  private
    def after_confirmation_path_for(_resource_name, resource)
      sign_in resource
      redirect_to new_company_path
    end
end
