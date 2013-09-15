require 'omniauth-oauth2'
require 'multi_json'
module OmniAuth
  module Strategies
    #taken from https://github.com/he9qi/omniauth_china/blob/55dac2d2a657d20711459f89dfeb802a8f06c81e/lib/omniauth_china/strategies/qzone.rb
    class Qzone < OmniAuth::Strategies::OAuth2
      option :name, 'qzone'
      
      option :client_options, {
        :site => 'https://graph.qq.com/oauth2.0/',
        :authorize_url => '/oauth2.0/authorize',
        :token_url => "/oauth2.0/token"
      }

      option :token_params, {
        :state => 'foobar',
        :parse => :query
      }

      
      uid { 
        @uid ||= begin
          access_token.options[:mode] = :query
          access_token.options[:param_name] = :access_token
          # Response Example: "callback( {\"client_id\":\"11111\",\"openid\":\"000000FFFF\"} );\n"
          response = access_token.get('/oauth2.0/me')
          #TODO handle error case
          matched = response.body.match(/"openid":"(?<openid>\w+)"/)
          matched[:openid]
        end
        
      }
      
      info do
        {
          'uid' => access_token.params[:openid],
          'nickname' => raw_info['nickname'],
          'name' =>  raw_info['nickname'],
          'image' => raw_info['figureurl'],
          'urls' => {
            'figureurl_1' =>raw_info['figureurl_1'],
            'figureurl_2' => raw_info['figureurl_2'],
          },
        }
      end
      extra do
        { :raw_info => raw_info }
      end
      def raw_info
        @raw_info ||= begin
          #TODO handle error case
          #TODO make info request url configurable
          
          client.request(:get, "https://graph.qq.com/user/get_user_info", :params => {
              :format => :json,
              :openid => uid,
              :oauth_consumer_key => options[:client_id],
              :access_token => access_token.token
            }, :parse => :json).parsed
        end
      end
    end
  end
end