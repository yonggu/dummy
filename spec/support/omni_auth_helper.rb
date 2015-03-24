module OmniAuthHelper
  def valid_bitbucket_login_setup(options = {})
    if Rails.env.test?
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:bitbucket] = OmniAuth::AuthHash.new({
        provider: 'bitbucket',
        uid: options[:uid] || '123456',
        info: {
          email: options[:info].try(:[], :email),
          name: options[:info].try(:[], :name)
        },
        credentials: {
          token: options[:credentials].try(:[], :token),
          secret: options[:credentials].try(:[], :secret),
        }
      })
    end
  end

  def valid_github_login_setup(options = {})
    if Rails.env.test?
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
        provider: 'github',
        uid: options[:uid] || '123456',
        info: {
          nickname: options[:info].try(:[], :nickname),
          name: options[:info].try(:[], :name),
          email: options[:info].try(:[], :email)
        },
        credentials: {
          token: options[:credentials].try(:[], :token),
          secret: options[:credentials].try(:[], :secret)
        }
      })
    end
  end
end
