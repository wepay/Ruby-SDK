require 'cgi'
require 'json'
require 'net/http'
require 'net/https'
require 'rubygems'
require 'uri'

class WePay

  STAGE_API_ENDPOINT = "https://stage.wepayapi.com/v2"
  STAGE_UI_ENDPOINT = "https://stage.wepay.com/v2"

  PRODUCTION_API_ENDPOINT = "https://wepayapi.com/v2"
  PRODUCTION_UI_ENDPOINT = "https://www.wepay.com/v2"

  ##
  # Initializes the API application.
  ##
  def initialize(client_id, client_secret, use_stage = true, api_version = nil)
    @client_id = client_id
    @client_secret = client_secret
    @api_version = api_version

    if use_stage
      @api_endpoint = STAGE_API_ENDPOINT
      @ui_endpoint = STAGE_UI_ENDPOINT
    else
      @api_endpoint = PRODUCTION_API_ENDPOINT
      @ui_endpoint = PRODUCTION_UI_ENDPOINT
    end
  end

  ##
  # Execute a call to the WePay API.
  ##
  def call(call, access_token = false, params = {})
    url = URI.parse(@api_endpoint + (call[0,1] == '/' ? call : "/#{ call }"))
    call = Net::HTTP::Post.new(url.path, initheader = {
      'Content-Type' => 'application/json',
      'User-Agent'   => 'WePay Ruby SDK'
    })

    unless params.empty?{}
      params = params.merge({
        "client_id"     => @client_id,
        "client_secret" => @client_secret
      })
    end

    if access_token then call.add_field('Authorization: Bearer', access_token); end
    if @api_version then call.add_field('Api-Version', @api_version); end

    make_request(call, url)
  end

  def make_request(call, url)
    request = Net::HTTP.new(url.host, url.port)
    request.read_timeout = 30
    request.use_ssl = true
    response = request.start {|http| http.request(call) }
    JSON.parse(response.body)
  end

  ##
  # Returns the OAuth 2.0 URL that users should be redirected to for
  # authorizing your API application. The `redirect_uri` must be a
  # fully-qualified URL (e.g., `https://www.wepay.com`).
  ##
  def oauth2_authorize_url(
    redirect_uri,
    user_email = false,
    user_name = false,
    permissions = "manage_accounts,collect_payments,view_user,send_money,preapprove_payments,manage_subscriptions"
  )
    url = @ui_endpoint
        + '/oauth2/authorize?client_id=' + @client_id.to_s
        + '&redirect_uri=' + redirect_uri
        + '&scope=' + permissions

    url += user_name ? '&user_name=' + CGI::escape(user_name) : ''
    url += user_email ? '&user_email=' + CGI::escape(user_email) : ''
  end

  #this function will make a call to the /v2/oauth2/token endpoint to exchange a code for an access_token
  def oauth2_token(code, redirect_uri)
    call('/oauth2/token', false, {
      'client_id'     => @client_id,
      'client_secret' => @client_secret,
      'redirect_uri'  => redirect_uri,
      'code'          => code
    })
  end
end
