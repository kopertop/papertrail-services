# encoding: utf-8
class Service::Silverline < Service
  def receive_logs
    count = payload[:events].length

    http_post 'https://metrics-api.librato.com/v1/metrics.json' do |req|
      req.body = {
        :gauges => {
          settings[:name] => {
            :value => count
          }
        }
      }
    end
  end
end