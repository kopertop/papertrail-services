# encoding: utf-8
class Service::Silverline < Service
  def receive_logs
    count = payload[:events].length

    http.basic_auth settings[:user], settings[:token]

    res = http_post 'https://metrics-api.librato.com/v1/metrics.json' do |req|
      req.headers[:content_type] = 'application/json'

      req.body = {
        :gauges => {
          settings[:name] => {
            :value => count
          }
        }
      }.to_json
    end
  end
end