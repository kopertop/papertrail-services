module PapertrailServices
  class App < Sinatra::Base
    def self.service(svc)
      post "/#{svc.hook_name}/:event" do
        settings = HashWithIndifferentAccess.new(JSON.parse(params[:settings]))
        payload  = HashWithIndifferentAccess.new(JSON.parse(params[:payload]))
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
    
    def report_exception(e)
    end
  end
end
