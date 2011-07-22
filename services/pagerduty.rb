class Service::Pagerduty < Service
  def receive_logs
    
    options[:url]  = "https://events.pagerduty.com/generic/2010-04-15"
    
    
    body = {
      :service_key => settings[:service_key],
      :event_type => settings[:event_type],
      :description => settings[:description],
    }

    body[:incident_key] = settings[:incident_key] if settings[:incident_key]
    details = {
      :message => payload[:events].first['message']
    }

    if settings[:base_url]
      details[:log_start_url] =
        "#{settings[:base_url]}?centered_on_id=#{payload[:min_id]}"
      details[:log_end_url] =
        "#{settings[:base_url]}?centered_on_id=#{payload[:max_id]}"
    end

    body[:details] = Yajl::Encoder.encode(details)

    result = pagerduty.post 'create_event.json' do |req|
      req.body = body
    end

    result.success? ? 'ok' : 'error'
  end
end