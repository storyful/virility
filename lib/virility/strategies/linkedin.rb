module Virility
  class Linkedin < Strategy

    parser(
      Proc.new do |body, format|
        MultiJson.decode(body.scan(/(\{.+\})/).flatten.first)
      end
    )

    def census
      params = {
        url: @original_url,
        format: 'json'
      }
      self.class.get("http://www.linkedin.com/countserv/count/share", query: params)
    end

    def count
      results[:count] || 0
    end

  end
end