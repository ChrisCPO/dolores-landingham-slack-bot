class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:oauth_callback]

  def oauth_callback
    if ok_to_bypass_authentication?
      create_user(developer_email)
    else
      if team_member?
        create_user(auth_email)
      end
    end
  end

  private

  def create_user(email)
    user = User.find_or_create_by(email: email)
    sign_in(user)
    flash[:success] = "You successfully signed in"
    redirect_to root_path
  end

  def ok_to_bypass_authentication?
    Rails.env == "development" && skip_team_check?
  end

  def skip_team_check?
    ENV["SKIP_TEAM_CHECK"].downcase == "true"
  end

  def developer_email
    ENV["DEVELOPER_EMAIL"]
  end

  def team_member?
    auth_hash.credentials.team_member?
  end

  def auth_email
    info.email
  end

  def info
    auth_hash.info
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
