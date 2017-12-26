class NotificationMailer < ApplicationMailer
  default from: "imbadpuck@gmail.com"
 # Sends email to user when user has notification
  # NotificationMailer.sample_email(@user).deliver
  layout "mailer"
  def sample_email(user)
    @user = user
    mail(to: @user.email, subject: 'Sample Email')
  end
end
