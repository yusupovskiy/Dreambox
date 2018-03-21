class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.welcome.subject
  #
  def welcome
    @greeting = "Hi"

    mail to: 'tryij@tioo.ru', subject: 'Welcome!'
    # mail to: 'fgvcxbai@gmail.com', subject: 'Welcome!'
  end
end
