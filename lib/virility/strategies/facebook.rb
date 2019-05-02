module Virility
  class Facebook < Strategy
    BASE_URL = 'https://graph.facebook.com/' \
                "?access_token=#{@facebook_token}" \
                '&fields=engagement' \
                '&id='.freeze

    def census
      self.class.get("#{BASE_URL}#{@url}",
                     http_proxyaddr: @http_proxyaddr,
                     http_proxyport: @http_proxyport)
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
  end
end
