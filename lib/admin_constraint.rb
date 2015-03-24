class AdminConstraint
  def matches?(request)
    request.env['warden'].authenticate!(scope: :user) && request.env['warden'].user(:user).admin?
  end
end
