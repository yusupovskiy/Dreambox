class ConfirmationsController < Devise::ConfirmationsController
  private
    def after_confirmation_path_for(_resource_name, resource)
      sign_in resource
      # new_company_path
      persons_profile_path
    end
end
