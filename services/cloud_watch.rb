class Service::CloudWatch < Service
  attr_writer :acw
  
  def receive_logs
    data_points = PapertrailServices::Helpers::EventMetrics.prepare(payload[:events], settings[:name], settings[:regex])
        
    return if data_points.empty?

    acw.put_metric_data(:namespace => settings[:namespace] || 'Papertrail', :data => data_points)
  end

  def acw
    @acw ||= RightAws::AcwInterface.new(settings[:access_key_id], settings[:secret_key])
  end
end