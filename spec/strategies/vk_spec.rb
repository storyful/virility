require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Virility::Vk" do
  before(:each) do
    @url = "http://creativeallies.com"
  end

  describe "poll" do
    context "when there is not a valid result" do
      before(:each) do
        response = double("HTTParty::Response", :body => 'VK.Share.count();')
        allow(Virility::Vk).to receive(:get) { response }
        @virility = Virility::Vk.new(@url)
      end

      it_should_behave_like "no context results"
    end

    context "when there is no result" do
      before(:each) do
        response = double("HTTParty::Response", :body => 'VK.Share.count();')
        allow(Virility::Vk).to receive(:get) { response }
        @virility = Virility::Vk.new(@url)
      end

      it_should_behave_like "no context results"
    end

    context "when there is a valid result" do
      before(:each) do
        response = double(
          "HTTParty::Response", :body => 'VK.Share.count(0, 6);'
        )
        allow(Virility::Vk).to receive(:get) { response }
        @virility = Virility::Vk.new(@url)
      end

      it "should not raise an error" do
        expect{ @virility.poll }.not_to raise_error
      end

      it "should return 6 for the count" do
        expect(@virility.count).to eq(6)
      end
    end
  end
end
