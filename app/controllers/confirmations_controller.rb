class ConfirmationsController < Devise::ConfirmationsController
  private
    def after_confirmation_path_for(_resource_name, resource)
      p '+'*10
      sign_in resource
      '/'
    end
end
