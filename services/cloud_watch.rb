class Service::CloudWatch < Service
  attr_writer :acw
  
  def receive_logs
    data_points = prepare(payload[:events], settings[:name], settings[:regex])
        
    return if data_points.empty?

    acw.put_metric_data(:namespace => settings[:namespace] || 'Papertrail', :data => data_points)
  end

  def acw
    @acw ||= RightAws::AcwInterface.new(settings[:aws_access_key_id], settings[:aws_secret_access_key])
  end
  
  def prepare(events, name, regex)
    unless regex
      # count all events as a single data point
      return [{ 
        :metric_name => name,
        :value => events.length,
        :timestamp => Time.now.utc.strftime('%FT%XZ')
      }]
    end

    data_points_for_metric(name, events, Regexp.new(regex))
  end
  
  def data_points_for_metric(name, events, regex)
    data_points = []
          
    events.each do |event|
      value = nil
      if regex
        match_data = event[:message].match(regex)
        # regex provided and does not match event
        next unless match_data
    
        # use extracted value
        value = match_data[1].to_i if match_data[1]
      else
        # no regex used (or no backref used), so this is basically an 
        # unaggregated counter
        value = 1
      end
  
      data_points << { 
        :metric_name => name,
        :value => value,
        :timestamp => event[:received_at]
      } if value
    end
    
    data_points
  end
  
end