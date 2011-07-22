module PapertrailServices
  class Service
    TIMEOUT = 20

    def self.receive(event, settings, payload)
      svc = new(event, settings, payload)
      
      event_method = "receive_#{event}".to_sym
      if svc.respond_to?(event_method)
        Timeout.timeout(TIMEOUT, TimeoutError) do
          svc.send(event_method)
        end
        
        true
      else
        false
      end
    end
    
    def self.inherited(svc)
      PapertrailServices::Service.services << svc
      PapertrailServices::App.service(svc)
      super
    end
    
    attr_reader :event
    attr_reader :settings
    attr_reader :payload
    
    def initialize(event, settings, payload)
      @event    = event
      @settings = settings
      @payload  = payload
    end
    
    def http_get(url = nil, params = nil, headers = nil)
      http.get do |req|
        req.url(url)                if url
        req.params.update(params)   if params
        req.headers.update(headers) if headers
        yield req if block_given?
      end
    end
    
    def http_post(url = nil, body = nil, headers = nil)
      http.post do |req|
        req.url(url)                if url
        req.headers.update(headers) if headers
        req.body = body             if body
        yield req if block_given?
      end
    end
    
    def http_method(method, url = nil, body = nil, headers = nil)
      http.send(method) do |req|
        req.url(url)                if url
        req.headers.update(headers) if headers
        req.body = body             if body
        yield req if block_given?
      end
    end
    
    def http(options = {})
      @http ||= begin
        options[:timeout]            ||= 6
        options[:ssl]                ||= {}
        options[:ssl][:ca_file]      ||= ca_file
        options[:ssl][:verify_depth] ||= 5

        Faraday.new(options) do |b|
          b.request :url_encoded
          b.adapter :net_http
        end
      end
    end
    
    def raise_config_error(msg = "Invalid configuration")
      raise ConfigurationError, msg
    end
    
    # Gets the path to the SSL Certificate Authority certs.  These were taken
    # from: http://curl.haxx.se/ca/cacert.pem
    def ca_file
      @ca_file ||= File.expand_path('../../config/cacert.pem', __FILE__)
    end
    
    class TimeoutError < StandandError; end
    class ConfigurationError < StandardError; end
  end
end

::Service = PapertrailServices::Service