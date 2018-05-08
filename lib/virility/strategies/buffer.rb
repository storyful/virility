module Virility
  class Buffer < Strategy

    parser(
      Proc.new do |body, format|
        MultiJson.decode(body.scan(/(\{.+\})/).flatten.first)
      end
    )

    def census
      self.class.get(
        "https://api.bufferapp.com/1/links/shares.json?url=#{@url}",
        http_proxyaddr: @http_proxyaddr,
        http_proxyport: @http_proxyport
      )
    end

    def count
      results["shares"] || 0
    end

  end
end
