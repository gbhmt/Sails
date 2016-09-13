require 'rack'
require 'flash'
require 'controller_base'

describe Flash do
  let(:req) { Rack::Request.new({'rack.input' => {}}) }
  let(:res) { Rack::Response.new([], '200', {}) }
  let(:flash) { Flash.new(req) }

  describe "#[]=" do
    it "sets data in flash" do
      flash['golden gate park'] = 'bison'
      expect(flash['golden gate park']).to eq('bison')
    end
  end

  describe "#store_flash" do
    before(:each) do
      flash['first_key'] = 'first_val'
      flash.store_flash(res)
    end

    it "adds new cookie with '_rails_lite_app_flash' name to response" do
      cookie_str = res.headers['Set-Cookie']
      cookie = Rack::Utils.parse_query(cookie_str)
      expect(cookie["_rails_lite_app_flash"]).not_to be_nil
    end

    it "stores the cookie in JSON format" do
      cookie_str = res.headers['Set-Cookie']
      cookie = Rack::Utils.parse_query(cookie_str)
      cookie_val = cookie["_rails_lite_app_flash"]
      cookie_hash = JSON.parse(cookie_val)

      expect(cookie_hash).to be_instance_of(Hash)
      expect(cookie_hash['first_key']).to eq('first_val')
    end
  end

  describe "#[]" do
    it "reads data from flash cookie" do
      cookie = { '_rails_lite_app_flash' => { "best_pizza" => "Arizmendi" }.to_json }
      req.cookies.merge!(cookie)
      updated_flash = Flash.new(req)
      expect(updated_flash["best_pizza"]).to eq("Arizmendi")
    end

    it "can be accessed using either strings or symbols" do
      flash = Flash.new(req)
      flash["notice"] = "test"
      expect(flash[:notice]).to eq("test")
    end
  end

  describe "#now" do
    before(:each) do
      flash.now["abc"] = "xyz"
    end

    it "reads data from flash.now" do
      expect(flash["abc"]).to eq("xyz")
    end

    it "does not persist flash.now data" do
      flash.store_flash(res)
      cookie_str = res.headers['Set-Cookie']
      cookie = Rack::Utils.parse_query(cookie_str)
      cookie_val = cookie["_rails_lite_app_flash"]
      cookie_hash = JSON.parse(cookie_val)
      expect(cookie_hash["abc"]).to be_nil
    end
  end
end
