class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def after_sign_in_path_for(resource)
    shelters_path
  end

  # Devise calls this after registrations#create (new accounts)
  def after_sign_up_path_for(resource)
    shelters_path
  end
end
