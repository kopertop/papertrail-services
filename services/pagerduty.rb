# encoding: utf-8
class Service::Pagerduty < Service
  def receive_logs
    body = {
      :service_key => settings[:service_key],
      :event_type => settings[:event_type],
      :description => settings[:description],
      :details => {
        :message => payload[:events].first && payload[:events].first[:message]
      }
    }

    body[:incident_key] = settings[:incident_key] if settings[:incident_key].present?

    body[:details] = {

    }

    if settings[:base_url].present?
      body[:details][:log_start_url] =
        "#{settings[:base_url]}?centered_on_id=#{payload[:min_id]}"
      body[:details][:log_end_url] =
        "#{settings[:base_url]}?centered_on_id=#{payload[:max_id]}"
    end

    http_post "https://events.pagerduty.com/generic/2010-04-15/create_event.json", body
  end
end