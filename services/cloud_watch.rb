class Service::CloudWatch < Service
  attr_writer :acw
  
  def receive_logs
    metrics = PapertrailServices::Helpers::EventMetrics.prepare(payload[:events], settings[:metric])
    
    data_points = add_dimensions_if_provided(metrics)
    
    return if data_points.empty?

    acw.put_metric_data(:namespace => settings[:namespace] || 'Papertrail', :data => data_points)
  end

  def acw
    @acw ||= RightAws::AcwInterface.new(settings[:access_key_id], settings[:secret_key])
  end
  
  def add_dimensions_if_provided(metrics)
    data_points = []
    
    metrics.each do |metric_id,metric|
      metric[:data_points].each_with_index do |data_point,i|
        if data_point[:dimension]
          # turn query params into input params
          dimensions = {}
          data_point[:dimension].split(';').each do |dimension|
            name, value = dimension.split('=')
            dimensions[name] = value
          end
          data_point[:dimension] = dimensions
        end
      end

      data_points += metric[:data_points]
    end
    
    data_points
  end
end