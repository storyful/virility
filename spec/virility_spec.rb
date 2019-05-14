require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Virility" do

  before do
    koala = instance_double(Koala::Facebook::API, access_token: 'abc')
    oauth = instance_double(Koala::Facebook::OAuth, get_app_access_token: 123)
    allow(Koala::Facebook::API).to receive(:new).and_return(koala)
    allow(Koala::Facebook::OAuth).to receive(:new).and_return(oauth)
  end

  #
  # Factory
  #

  describe "factory" do
    context "valid strategies" do
      Virility::TESTING_STRATEGIES.each do |strategy, object|
        it "#{strategy} should create and return a #{object} object" do
          expect(Virility.factory(strategy, "http://creativeallies.com")).to be_a_kind_of(object)
        end
      end
    end

    context "invalid strategies" do
      Virility::FAKE_TESTING_STRATEGIES.each do |strategy|
        it "#{strategy} should raise an error" do
          expect{ Virility.factory(strategy, "http://creativeallies.com") }
            .to raise_error(Virility::UnknownStrategy, "#{strategy} Is Not A Known Strategy")
        end
      end
    end
  end

  #
  # Public API
  #

  context 'URLs with ids in parameters' do
    it 'gets the engagement numbers for the correct URL' do
      urls = ['http://therealnews.com/t2/index.php?option=com_content&task=view&id=31&Itemid=74&jumival=18108',
              'http://www.nzherald.co.nz/world/news/article.cfm?c_id=2&objectid=11785185&ref=rss',
              'http://www.nzherald.co.nz/business/news/article.cfm?c_id=3&objectid=11784904&ref=rss',
              'http://www.nzherald.co.nz/hawkes-bay-today/news/article.cfm?c_id=1503462&objectid=11784368&ref=rss']

      urls.each do |test_url|
        response = Virility.url(test_url)
        expect(response.strategies[:linkedin].response['url']).to eq(test_url)
        expect(response.strategies[:pinterest].response['url']).to eq(test_url)
        # TODO: stumble_upon, reddit, plus_one
      end
    end
  end

  describe "Public API testing" do
    before(:each) do
      @url = "http://creativeallies.com"
      allow(Virility::Buffer).to receive(:get) { double("HTTParty::Response", :parsed_response => {"shares"=>5}) }
      allow(Virility::Facebook).to receive(:get) { double("HTTParty::Response", :parsed_response => {"engagement"=>{"reaction_count"=>0, "comment_count"=>0, "share_count"=>20, "comment_plugin_count"=>0}, "id"=>"https://www.youtube.com/channel/UCiCr0_2qhfa-xP6gpMfDG0Q"}) }
      allow(Virility::Pinterest).to receive(:get) { double("HTTParty::Response", :parsed_response => {"count"=>1, "url"=>"http://creativeallies.com"}) }
      allow(Virility::PlusOne).to receive(:get) { double("HTTParty::Response", :parsed_response => {"shares"=>"8"}) }
      allow(Virility::StumbleUpon).to receive(:get) { double("HTTParty::Response", :parsed_response => {"url"=>"http://creativeallies.com/", "in_index"=>true, "publicid"=>"2UhTwK", "views"=>4731, "title"=>"Creative Allies | Create Art For Rockstars | Upload For A Chance To Win", "thumbnail"=>"http://cdn.stumble-upon.com/mthumb/388/49348388.jpg", "thumbnail_b"=>"http://cdn.stumble-upon.com/images/nobthumb.png", "submit_link"=>"http://www.stumbleupon.com/submit/?url=http://creativeallies.com/", "badge_link"=>"http://www.stumbleupon.com/badge/?url=http://creativeallies.com/", "info_link"=>"http://www.stumbleupon.com/url/creativeallies.com/"}) }
      allow(Virility::Linkedin).to receive(:get) { double("HTTParty::Response", :parsed_response => { "count":17, "fCnt":"17", "fCntPlusOne":"18", "url":"http:\/\/creativeallies.com" }) }
      allow(Virility::Reddit).to receive(:get) { double("HTTParty::Response", :parsed_response => { "data" => { "children" => [{ "data" => { "domain" => "apple.com", "banned_by" => nil, "media_embed" => {}, "num_reports" => nil, "score" => 1}}, { "data" => { "domain" => "apple.com", "banned_by" => nil, "media_embed" => {}, "num_reports" => nil, "score" => 34 }}]}})}
    end

    it "Virility.counts should return a hash of counts" do
      expect(Virility.counts(@url)).to eq(
        { buffer: 5, facebook: 20, linkedin: 17, pinterest: 1, plus_one: 8,
          reddit: 35, stumble_upon: 4731, vk: 14 }
      )
    end

    it "Virility.total should return the total count" do
      expect(Virility.total(@url)).to eq(4831)
    end

    it "Virility.poll should return all of the hashed responses" do
      expect(Virility.poll(@url)).to eq(
        { :buffer=>{"shares"=>5},
          :facebook=>{"comment_count"=>0, "comment_plugin_count"=>0, "engagement_count"=>20, "reaction_count"=>0, "share_count"=>20, "social_sentence"=>0},
          :linkedin=>{ "count":17, "fCnt":"17", "fCntPlusOne":"18", "url":"http:\/\/creativeallies.com" },
          :pinterest=>{"count"=>1, "url"=>"http://creativeallies.com"},
          :plus_one=>{"shares"=>"8"},
          :stumble_upon=>{"url"=>"http://creativeallies.com/", "in_index"=>true, "publicid"=>"2UhTwK", "views"=>4731, "title"=>"Creative Allies | Create Art For Rockstars | Upload For A Chance To Win", "thumbnail"=>"http://cdn.stumble-upon.com/mthumb/388/49348388.jpg", "thumbnail_b"=>"http://cdn.stumble-upon.com/images/nobthumb.png", "submit_link"=>"http://www.stumbleupon.com/submit/?url=http://creativeallies.com/", "badge_link"=>"http://www.stumbleupon.com/badge/?url=http://creativeallies.com/", "info_link"=>"http://www.stumbleupon.com/url/creativeallies.com/"},
          :reddit=>{"score"=>35 },
          :vk=>{"shares"=>14 }
        }
      )
    end
    it "Virility.poll should return all of the hashed responses with filtered strategies only" do
      expect(Virility.poll(@url, strategies: [:buffer,:facebook,:linkedin,:pinterest,:plus_one,:stumble_upon])).to eq({
        :buffer=>{"shares"=>5},
        :facebook=>{"comment_count"=>0, "comment_plugin_count"=>0, "engagement_count"=>20, "reaction_count"=>0, "share_count"=>20, "social_sentence"=>0},
        :linkedin=>{ "count":17, "fCnt":"17", "fCntPlusOne":"18", "url":"http:\/\/creativeallies.com" },
        :pinterest=>{"count"=>1, "url"=>"http://creativeallies.com"},
        :plus_one=>{"shares"=>"8"},
        :stumble_upon=>{"url"=>"http://creativeallies.com/", "in_index"=>true, "publicid"=>"2UhTwK", "views"=>4731, "title"=>"Creative Allies | Create Art For Rockstars | Upload For A Chance To Win", "thumbnail"=>"http://cdn.stumble-upon.com/mthumb/388/49348388.jpg", "thumbnail_b"=>"http://cdn.stumble-upon.com/images/nobthumb.png", "submit_link"=>"http://www.stumbleupon.com/submit/?url=http://creativeallies.com/", "badge_link"=>"http://www.stumbleupon.com/badge/?url=http://creativeallies.com/", "info_link"=>"http://www.stumbleupon.com/url/creativeallies.com/"}
      })
    end
    it "Virility.poll should return all of the hashed responses with filtered strategies only" do
      expect(Virility.poll(@url, strategies: [:buffer,:facebook,:linkedin,:pinterest,:plus_one,:stumble_upon])).to eq({
        :buffer=>{"shares"=>5},
        :facebook=>{"comment_count"=>0, "comment_plugin_count"=>0, "engagement_count"=>20, "reaction_count"=>0, "share_count"=>20, "social_sentence"=>0},
        :linkedin=>{ "count":17, "fCnt":"17", "fCntPlusOne":"18", "url":"http:\/\/creativeallies.com" },
        :pinterest=>{"count"=>1, "url"=>"http://creativeallies.com"},
        :plus_one=>{"shares"=>"8"},
        :stumble_upon=>{"url"=>"http://creativeallies.com/", "in_index"=>true, "publicid"=>"2UhTwK", "views"=>4731, "title"=>"Creative Allies | Create Art For Rockstars | Upload For A Chance To Win", "thumbnail"=>"http://cdn.stumble-upon.com/mthumb/388/49348388.jpg", "thumbnail_b"=>"http://cdn.stumble-upon.com/images/nobthumb.png", "submit_link"=>"http://www.stumbleupon.com/submit/?url=http://creativeallies.com/", "badge_link"=>"http://www.stumbleupon.com/badge/?url=http://creativeallies.com/", "info_link"=>"http://www.stumbleupon.com/url/creativeallies.com/"}
      })
    end

    it "Virility.url should return a Virility::Excitation object" do
      expect(Virility.url(@url)).to be_a_kind_of(Virility::Excitation)
    end
  end

  #
  # Error Proofing
  #

  describe "Error Proofing" do
    it "should not raise an error with a bad URL" do
      expect{ Virility.counts("http://this.is.a.crap.url") }.not_to raise_error
    end

    it "should return 0 for all strategy counts" do
      @virility = Virility.url("http://this.is.a.crap.url")
      expect(@virility.total).to eq(0)
      expect(@virility.counts).to eq(
        { buffer: 0, facebook: 0, linkedin: 0, pinterest: 0, plus_one: 0,
          reddit: 0, stumble_upon: 0, vk: 0 }
      )
    end
  end
end
