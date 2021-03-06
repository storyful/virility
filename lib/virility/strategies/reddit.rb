module Virility
  class Reddit < Strategy

    def census
      self.class.get(
        "https://www.reddit.com/api/info.json?&url=#{@url}",
        http_proxyaddr: @http_proxyaddr,
        http_proxyport: @http_proxyport
      )
    end

    def outcome
      score = @response.parsed_response['data']['children'].map { |c| c['data']['score'] }.reduce(:+) || 0
      { 'score' => score }
    end

    def count
      results['score'] || 0
    end

  private

    def valid_response_test
      @response.respond_to?(:parsed_response) \
      && @response.parsed_response.is_a?(Hash) \
      && !@response.parsed_response['data'].nil? \
      && !@response.parsed_response['data']['children'].map { |c| c['data']['score'] }.nil?
    end
  end
end
