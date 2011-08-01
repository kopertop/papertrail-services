module PapertrailServices
  module Helpers
    module EventMetrics
      def self.prepare(events, metrics)
        if metrics.length == 1 && !metrics.values.first[:regex]
          # count all events as a single data point
          return [{ 
            :metric_name => metrics.values.first[:name],
            :value => events.length,
            :timestamp => Time.now.utc.strftime('%FT%XZ')
          }]
        end
  
        # generate one data point per metric per event. value is either extracted 
        # from the message or 1
        metrics.each do |metric_id,metric|
          regex = metric[:regex] && Regexp.new(metric[:regex])
          
          metric[:data_points] = data_points_for_metric(metric, events, regex)
        end
  
        metrics
      end
      
      def self.data_points_for_metric(metric, events, regex)
        data_points = []
              
        events.each do |event|
          value = nil
          if regex
            match_data = event[:message].match(regex)
            # regex provided and does not match event
            next unless match_data
        
            # use extracted value
            value = match_data[1].to_i if match_data[1]
          end

          # no regex used (or no backref used), so this is basically an 
          # unaggregated counter
          value ||= 1
      
          data_points << { 
            :metric_name => metric[:name],
            :value => value,
            :timestamp => event[:received_at]
          }
        end
        
        data_points
      end
      
    end
  end
end
