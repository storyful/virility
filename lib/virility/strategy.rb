module Virility
  class Strategy
    include HTTParty
    include Virility::Supporter

    attr_accessor :url, :response, :results, :original_url, :http_proxyaddr, :http_proxyport

    def initialize(url, proxy: {})
      @original_url = url
      @url = encode(url)
      @results = {}
      @http_proxyaddr = proxy.dig(:http_proxyaddr)
      @http_proxyport = proxy.dig(:http_proxyport)
    end

    #
    # Abstract Methods - Delete eventually
    #

    def census
      raise "Abstract Method census called on #{self.class} - Please define this method"
    end

    def count
      raise "Abstract Method count called on #{self.class} - Please define this method"
    end

    #
    # Poll
    #

    def poll
      call_strategy
      collect_results
    end

    #
    # Call Strategy
    #

    def call_strategy
      response = census
      if response.respond_to?(:key?) && response.key?('error')
        log("Virility error in #{self.class}: #{response['error']}")
      end
      @response = response
    end

    #
    # Results
    #

    def collect_results
      if respond_to?(:outcome)
        @results = valid_response_test ? outcome : {}
      else
        @results = valid_response_test ? @response.parsed_response : {}
      end
    end

    def results
      if @results.empty?
        begin
          poll
        rescue => e
          puts "[virility#poll] #{self.class.to_s} => #{e}"
        end
      end
      @results
    end

    #
    # Dynamic Methods
    #

    def get_result key
      if result_exists?(key)
        results[key.to_s]
      else
        0
      end
    end

    def result_exists? key
      !results[key.to_s].nil?
    end

    def method_missing(name, *args, &block)
      if result_exists?(name)
        get_result(name)
      else
        0
      end
    end

    #
    # Parsed Response Test - Overwrite if needed
    #

    def valid_response_test
      @response.respond_to?(:parsed_response) and @response.parsed_response.is_a?(Hash)
    end

    private

    def log(message)
      logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      logger.debug(message)
    end
  end
end
