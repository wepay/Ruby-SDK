require 'rubygems'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'

=begin
helps you make API calls to the WePay API v2
=end

class WePay
	
	STAGE_API_ENDPOINT = "https://stage.wepayapi.com/v2"
	STAGE_UI_ENDPOINT = "https://stage.wepay.com/v2"
	
	PRODUCTION_API_ENDPOINT = "https://wepayapi.com/v2"
	PRODUCTION_UI_ENDPOINT = "https://www.wepay.com/v2"
		
	# initializes the API application, api_endpoint should be something like 'https://stage.wepay.com/v2'
	def initialize(_client_id, _client_secret, _use_stage = true, _use_ssl = true, _api_version = nil)
		@client_id = _client_id
		@client_secret = _client_secret
		if _use_stage
			@api_endpoint = STAGE_API_ENDPOINT
			@ui_endpoint = STAGE_UI_ENDPOINT
		else
			@api_endpoint = PRODUCTION_API_ENDPOINT
			@ui_endpoint = PRODUCTION_UI_ENDPOINT
		end
		@use_ssl = _use_ssl
		@api_version = _api_version
	end
	
	# make a call to the WePay API
	def call(call, access_token = false, params = false)
		# get the url
		url = URI.parse(@api_endpoint + (call[0,1] == '/' ? call : "/#{ call }")
		# construct the call data and access token
		call = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json', 'User-Agent' => 'WePay Ruby SDK'})
		if params
			call.body = params.to_json
		end
		if access_token
			call.add_field('Authorization: Bearer', access_token);
		end
        
        # send Api Version header with call request
		if @api_version
			call.add_field('Api-Version', @api_version);
		end

		# create the request object
		request = Net::HTTP.new(url.host, url.port)
		request.read_timeout = 30
		request.use_ssl = @use_ssl
		# make the call
		response = request.start {|http| http.request(call) }
		# returns JSON response as ruby hash
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
