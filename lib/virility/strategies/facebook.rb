module Virility
  class Facebook < Strategy
    def base_url
      'https://graph.facebook.com/' \
              "?access_token=#{facebook_token}" \
              '&fields=engagement' \
              '&id='
    end

    def census
      self.class.get("#{base_url}#{@url}",
                     http_proxyaddr: @http_proxyaddr,
                     http_proxyport: @http_proxyport)
    end

    def facebook_token
      oauth = Koala::Facebook::OAuth.new(fb_app_id, fb_app_secret,
                                         'https://virility.test')
      token = Koala::Facebook::API.new(oauth.get_app_access_token)
      token.access_token
    end

    def outcome
      parsed_response = @response.parsed_response
      response = parsed_response.dig('engagement')
      response['engagement_count'] = response.dig('share_count')
      response['social_sentence'] = response.dig('reaction_count')
      response
    end

    def count
      results.dig('engagement_count') || 0
    end

    private

    def valid_response_test
      @response.respond_to?(:parsed_response) && \
        @response.parsed_response.is_a?(Hash) && \
        !@response.parsed_response['engagement'].nil?
    end

    def fb_app_sample
      @fb_app_sample ||= ENV['FB_APP_OAUTH_ARRAY']&.sample
    end

    def fb_app_id
      return fb_app_sample[:id] if fb_app_sample

      ENV['FB_APP_ID']
    end

    def fb_app_secret
      return fb_app_sample[:secret] if fb_app_sample

      ENV['FB_APP_SECRET']
    end
  end
end
