module PapertrailServices
  class App < Sinatra::Base
    def self.service(svc)
      post "/#{svc.hook_name}/:event" do
        begin
          settings = HashWithIndifferentAccess.new(json_decode(params[:settings]))
          payload  = HashWithIndifferentAccess.new(json_decode(params[:payload]))

          if svc.receive(:logs, settings, payload)
            status 200
            ''
          else
            status 404
            status "#{svc.hook_name} Service could not process request"
          end
        rescue Service::ConfigurationError => e
          status 400
          e.message
        rescue Object => e
          report_exception(e)
          status 500
          'error'
        end
      end

      get '/' do
        'ok'
      end

      def json_decode(value)
        Yajl::Parser.parse(value)
      end

      def json_encode(value)
        Yajl::Encoder.encode(value)
      end
    
      def report_exception(e)
        $stderr.puts "Error: #{e.class}: #{e.message}"
        $stderr.puts "\t#{e.backtrace.join("\n\t")}"
      end
    end
  end
end
