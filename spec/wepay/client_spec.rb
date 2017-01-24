require 'spec_helper'

RSpec.describe WePay::Client do

  context "constants" do
    it "returns the staging api endpoint" do
      expect(described_class::STAGE_API_ENDPOINT).to eq('https://stage.wepayapi.com/v2')
    end

    it "returns the staging ui endpoint" do
      expect(described_class::STAGE_UI_ENDPOINT).to eq('https://stage.wepay.com/v2')
    end

    it "returns the production api endpoint" do
      expect(described_class::PRODUCTION_API_ENDPOINT).to eq('https://wepayapi.com/v2')
    end

    it "returns the production ui endpoint" do
      expect(described_class::PRODUCTION_UI_ENDPOINT).to eq('https://www.wepay.com/v2')
    end
  end

  context "an instance" do
    subject do
      described_class.new(
        'client_id',
        'client_secret'
      )
    end

    describe "#initialize" do
      it "returns a client" do
        expect(subject).to be_a(described_class)
      end
    end

    describe "#api_endpoint" do
      context "for non-production environments" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            true
          )
        end

        it "returns the stage api endpoint" do
          expect(subject.api_endpoint).to eq('https://stage.wepayapi.com/v2')
        end
      end

      context "for production environments" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            false
          )
        end

        it "returns the production api endpoint" do
          expect(subject.api_endpoint).to eq('https://wepayapi.com/v2')
        end
      end
    end

    describe "#api_version" do
      context "when no version is given" do
        it "returns nothing" do
          expect(subject.api_version).to eq('')
        end
      end

      context "when a version is given" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            true,
            1
          )
        end

        it "returns the version" do
          expect(subject.api_version).to eq('1')
        end
      end
    end

    describe "#client_id" do
      it "returns the client id" do
        expect(subject.client_id).to eq('client_id')
      end
    end

    describe "#client_secret" do
      it "returns the client secret" do
        expect(subject.client_secret).to eq('client_secret')
      end
    end

    describe "#ui_endpoint" do
      context "for non-production environments" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            true
          )
        end

        it "returns the staging ui endpoint" do
          expect(subject.ui_endpoint).to eq('https://stage.wepay.com/v2')
        end
      end

      context "for production environments" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            false
          )
        end

        it "returns the production ui endpoint" do
          expect(subject.ui_endpoint).to eq('https://www.wepay.com/v2')
        end
      end
    end

    describe "#call" do
      let(:post_request)  { double('net::http::post') }
      let(:post_client)   { double('net::http') }
      let(:post_response) { double('net::http::response') }

      context "making a non-production request" do
        subject do
          described_class.new(
            'client_id',
            'client_secret'
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer ')
          allow(post_request).to receive(:add_field).with('Api-Version', '')

          allow(Net::HTTP).to receive(:new).with(
            'stage.wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end

        it "makes a staging request" do
          expect(subject.call('/app')).to eq('status' => 200)
        end
      end

      context "making a production request" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            false
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer ')
          allow(post_request).to receive(:add_field).with('Api-Version', '')

          allow(Net::HTTP).to receive(:new).with(
            'wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end

        it "makes a production request" do
          expect(subject.call('/app')).to eq('status' => 200)
        end
      end

      context "making a naked path api call" do
        subject do
          described_class.new(
            'client_id',
            'client_secret'
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer ')
          allow(post_request).to receive(:add_field).with('Api-Version', '')

          allow(Net::HTTP).to receive(:new).with(
            'stage.wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end

        it "resolves to the correct request path" do
          expect(subject.call('app')).to eq('status' => 200)
        end
      end

      context "making a versioned api call" do
        subject do
          described_class.new(
            'client_id',
            'client_secret',
            true,
            1
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer ')
          allow(post_request).to receive(:add_field).with('Api-Version', '1')

          allow(Net::HTTP).to receive(:new).with(
            'stage.wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end

        it "sets the API version" do
          expect(subject.call('/app')).to eq('status' => 200)
        end
      end

      context "making an authorized api call" do
        subject do
          described_class.new(
            'client_id',
            'client_secret'
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer access_token')
          allow(post_request).to receive(:add_field).with('Api-Version', '')

          allow(Net::HTTP).to receive(:new).with(
            'stage.wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end

        it "sets the access token" do
          expect(subject.call('/app','access_token')).to eq('status' => 200)
        end
      end

      context "making an api call with a payload" do
        subject do
          described_class.new(
            'client_id',
            'client_secret'
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:body=).with({ app_id: 1 }.to_json)
          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer access_token')
          allow(post_request).to receive(:add_field).with('Api-Version', '')

          allow(Net::HTTP).to receive(:new).with(
            'stage.wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end
        it "sets the post body" do
          expect(subject.call('/app','access_token', app_id: 1)).to eq('status' => 200)
        end
      end

      context "making an api call with risk headers" do
        subject do
          described_class.new(
            'client_id',
            'client_secret'
          )
        end

        before do
          allow(Net::HTTP::Post).to receive(:new).with(
            '/v2/app',
            {
              'Content-Type' => 'application/json',
              'User-Agent'   => 'WePay Ruby SDK'
            }
          ).and_return(post_request)

          allow(post_request).to receive(:body=).with({ app_id: 1 }.to_json)
          allow(post_request).to receive(:add_field).with('Authorization', 'Bearer access_token')
          allow(post_request).to receive(:add_field).with('Api-Version', '')
          allow(post_request).to receive(:add_field).with('WePay-Risk-Token', 'risk_token')
          allow(post_request).to receive(:add_field).with('Client-IP', 'client_ip')

          allow(Net::HTTP).to receive(:new).with(
            'stage.wepayapi.com',
            443
          ).and_return(post_client)

          allow(post_client).to receive(:read_timeout=).with(30)
          allow(post_client).to receive(:use_ssl=).with(true)
          allow(post_client).to receive(:start).and_return(post_response)

          allow(post_response).to receive(:body).and_return({ status: 200 }.to_json)
        end
        it "sets the risk headers" do
          expect(subject.call('/app','access_token', {app_id: 1}, 'risk_token','client_ip')).to eq('status' => 200)
        end
      end
    end

    describe "#oauth2_authorize_url" do
      context "with default params" do
        it "returns the oauth2 authorize url" do
          expect(
            subject.oauth2_authorize_url(
              'https://www.wepay.com'
            )
          ).to eq(
            'https://stage.wepay.com/v2/oauth2/authorize?client_id=client_id&redirect_uri=https://www.wepay.com&scope=manage_accounts,collect_payments,view_user,send_money,preapprove_payments,manage_subscriptions')
        end
      end

      context "with custom params" do
        it "returns the oauth2 authorize url" do
          expect(
            subject.oauth2_authorize_url(
              'https://www.wepay.com',
              'user@host.com',
              'username',
              'manage_accounts',
              'US United States'
            )
          ).to eq(
            'https://stage.wepay.com/v2/oauth2/authorize?client_id=client_id&redirect_uri=https://www.wepay.com&scope=manage_accounts&user_name=username&user_email=user%40host.com&user_country=US+United+States')
        end
      end
    end

    describe "#oauth2_token" do
      let(:post_request)  { double('net::http::post') }
      let(:post_client)   { double('net::http') }
      let(:post_response) { double('net::http::response') }

      subject do
        described_class.new(
          'client_id',
          'client_secret',
          false
        )
      end

      before do
        allow(Net::HTTP::Post).to receive(:new).with(
          '/v2/oauth2/token',
          {
            'Content-Type' => 'application/json',
            'User-Agent'   => 'WePay Ruby SDK'
          }
        ).and_return(post_request)

        allow(post_request).to receive(:body=).with(
          {
            client_id:     'client_id',
            client_secret: 'client_secret',
            redirect_uri:  'redirect.wepay.com',
            code:          'code'
          }.to_json
        )
        allow(post_request).to receive(:add_field).with('Authorization', 'Bearer ')
        allow(post_request).to receive(:add_field).with('Api-Version', '')

        allow(Net::HTTP).to receive(:new).with(
          'wepayapi.com',
          443
        ).and_return(post_client)

        allow(post_client).to receive(:read_timeout=).with(30)
        allow(post_client).to receive(:use_ssl=).with(true)
        allow(post_client).to receive(:start).and_return(post_response)

        allow(post_response).to receive(:body).and_return({ access_token: 'abc123' }.to_json)
      end

      it "returns a oauth2 token response" do
        expect(
          subject.oauth2_token(
            'code',
            'redirect.wepay.com',
          )
        ).to eq('access_token' => 'abc123')
      end
    end
  end
end
