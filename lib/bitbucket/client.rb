require 'bitbucket/configurable'

module Bitbucket
  class Client
    def initialize(options = {})
      Bitbucket::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || Bitbucket.instance_variable_get(:"@#{key}"))
      end

      consumer = OAuth::Consumer.new @client_id, @client_secret, site: Bitbucket::Default::ENDPOINT
      @token = OAuth::AccessToken.new(consumer, @access_token, @access_token_secret)
    end

    def user(name)
      get "/1.0/users/#{name}"
    end

    def privileges(full_name, uid)
      get "/1.0/privileges/#{full_name}/#{uid}"
    end

    def repositories
      JSON.parse get('/1.0/user/repositories')
    end

    def services(full_name, options = {})
      JSON.parse get("/1.0/repositories/#{full_name}/services", options)
    end

    def deploy_keys(repository_name)
      JSON.parse get("/1.0/repositories/#{repository_name}/deploy-keys")
    end

    def create_service(full_name, hook_url)
      JSON.parse post("/1.0/repositories/#{full_name}/services", { type: :post, URL: hook_url })
    end

    def delete_service(full_name, hook_id)
      delete "/1.0/repositories/#{full_name}/services/#{hook_id}"
    end

    def create_deploy_key(full_name, key, label)
      JSON.parse post("/1.0/repositories/#{full_name}/deploy-keys", { key: key, label: label })
    end

    def delete_deploy_key(repository_full_name, deploy_key_id)
      delete "/1.0/repositories/#{repository_full_name}/deploy-keys/#{deploy_key_id}"
    end

    def create_pull_request(full_name, options = {})
      JSON.parse post("/2.0/repositories/#{full_name}/pullrequests", JSON.generate({
        title: options[:title],
        description: options[:description],
        source: {
          branch: {
            name: options[:source_branch]
          },
          repository: {
            full_name: full_name
          }
        },
        destination: {
          branch: {
            name: options[:destination_branch]
          }
        }
      }), {'Content-Type' => 'application/json'})
    end

    def get(url, options = {})
      @token.get(url).body
    end

    def post(url, body = '', options = {})
      @token.post(url, body, options).body
    end

    def delete(url, options = {})
      @token.delete(url, options).body
    end
  end
end
