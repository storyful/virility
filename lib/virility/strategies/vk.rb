module Virility
  class Vk < Strategy
    def census
      self.class.get(
        "https://vk.com/share.php?act=count&url=#{@url}",
        http_proxyaddr: @http_proxyaddr,
        http_proxyport: @http_proxyport
      )
    end

    def outcome
      { 'shares' => @response.body[/^VK\.Share\.count\(\d, (\d+)\);$/, 1].to_i }
    end

    def count
      results.dig('shares') || 0
    end

    private

    def valid_response_test
      @response.respond_to?(:body) &&
        (@response.body =~ /^VK\.Share\.count\(\d, \d+\);$/) == 0
    end
  end
end
