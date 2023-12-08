require "test_helper"

describe "Links flow", :integration do
  describe "loading root page" do
    before(:all) do
      @entry = LinkEntry.create!(external_url: "some external url")

      get '/'
    end
    
    it "return HTTP 200" do
      assert_response :success
    end

    it "includes external_url and short_id" do
      assert_includes @response.body, @entry.external_url
      assert_includes @response.body, @entry.short_id
    end
  end
end
