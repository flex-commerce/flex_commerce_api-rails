require 'rails_helper'

class CSPController < ActionController::Base
  include ShiftCommerce::ContentSecurityPolicy

  def index
    render nothing: true
  end
end


describe ShiftCommerce::ContentSecurityPolicy, type: :controller do
  let(:controller) { CSPController.new }
  let(:headers)    { response.headers }
  let(:csp_header) { headers['Content-Security-Policy'] }


  before do
    @controller = CSPController.new
    Rails.application.routes.draw do
      get '/csp' => 'csp#index'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context 'with the CSP' do
    it "should have the correct Content Security Policy" do
      get :index
      expect(headers).to have_key('Content-Security-Policy')
      expect(csp_header).to include("default-src 'self'")
      expect(csp_header).to include("base-uri 'self';")
      expect(csp_header).to include("object-src 'none';")
    end
  end
end