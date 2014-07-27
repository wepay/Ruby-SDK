require 'rubygems'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'

class WePay
  
  STAGE_API_ENDPOINT = "https://stage.wepayapi.com/v2"
  STAGE_UI_ENDPOINT = "https://stage.wepay.com/v2"
  
  PRODUCTION_API_ENDPOINT = "https://wepayapi.com/v2"
  PRODUCTION_UI_ENDPOINT = "https://www.wepay.com/v2"
    
  def initialize(client_id, client_secret, use_stage = true, api_version = nil)
    @client_id = client_id
    @client_secret = client_secret
    if use_stage
      @api_endpoint = STAGE_API_ENDPOINT
      @ui_endpoint = STAGE_UI_ENDPOINT
    else
      @api_endpoint = PRODUCTION_API_ENDPOINT
      @ui_endpoint = PRODUCTION_UI_ENDPOINT
    end
    @api_version = api_version
  end
  
  def call(call, access_token = false, params = {}, authenticated_call = true)
    url = URI.parse(@api_endpoint + call)
    call = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json', 'User-Agent' => 'WePay Ruby SDK'})
    unless params.empty?
      if authenticated_call then params = params.merge({"client_id" => @client_id, "client_secret" => @client_secret}); end
      call.body = params.to_json
    end
    call = add_call_headers(call, access_token)
    make_request(call, url)
  end

  def add_call_headers(current_call, access_token=false)
    if access_token then current_call.add_field('Authorization: Bearer', access_token); end
    if @api_version then current_call.add_field('Api-Version', @api_version); end
    return current_call
  end

  def make_request(call, url)
    request = Net::HTTP.new(url.host, url.port)
    request.read_timeout = 30
    request.use_ssl = true
    response = request.start {|http| http.request(call) }
    JSON.parse(response.body)
  end
  
  # this function returns the URL that you send the user to to authorize your API application
  # the redirect_uri must be a full uri (ex https://www.wepay.com)
  def oauth2_authorize_url(redirect_uri, user_email = false, user_name = false, permissions = "manage_accounts,collect_payments,view_user,send_money,preapprove_payments,manage_subscriptions")
    url = @ui_endpoint + '/oauth2/authorize?client_id=' + @client_id.to_s + '&redirect_uri=' + redirect_uri + '&scope=' + permissions
    url += user_name ? '&user_name=' + CGI::escape(user_name) : ''
    url += user_email ? '&user_email=' + CGI::escape(user_email) : ''
  end
  
  #this function will make a call to the /v2/oauth2/token endpoint to exchange a code for an access_token
  def oauth2_token(code, redirect_uri)
    call('/oauth2/token', false, {'client_id' => @client_id, 'client_secret' => @client_secret, 'redirect_uri' => redirect_uri, 'code' => code })
  end
end
