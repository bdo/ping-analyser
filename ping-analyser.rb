require 'time'
require 'chronic_duration'

lines = IO.read(File.expand_path(ARGV[0] || '~/ping.log')).lines
lines.delete_at(0)
end_time = Time.now
start_time = end_time - lines.length
results = {
  true => [],
  false => []
}

last_success = nil
last_count = 0
lines.each_with_index do |line, index|
  time = start_time + index
  line =~ /time=(.*) ms/
  value = $1
  success = value ? true : false
  if last_success == success
    last_count += 1
  else
    if last_count != 0
      results[last_success] << {time: time - last_count, count: last_count}
    end
    last_count = 1
    last_success = success
  end
end

puts "Started ping at #{start_time.strftime("%d/%m/%Y %H:%M:%S")} and stopped at #{end_time.strftime("%d/%m/%Y %H:%M:%S")}\n"

puts "Average duration timing out: #{ChronicDuration.output(results[false].reduce(0.0) {|sum,el| sum + el[:count] } / results[false].length)}" unless results[false].empty?
puts "Average duration without timeouts: #{ChronicDuration.output(results[true].reduce(0.0) {|sum,el| sum + el[:count] } / results[true].length)}" unless results[true].empty?

longuest_failure_ever = results[false].map{ |el| el[:count] }.max
puts "longuest timeout: #{ChronicDuration.output(longuest_failure_ever)}" if longuest_failure_ever

longuest_time_without_timeouts = results[true].map{ |el| el[:count] }.max
puts "longuest time without a timeout: #{ChronicDuration.output(longuest_time_without_timeouts)}" if longuest_time_without_timeouts

top_5_good_times = results[true].sort_by { |el| -el[:count] }.first(5)
puts "top 5 times without a timeout:\n\t#{top_5_good_times.map { |item| "#{item[:time].strftime("%d/%m/%Y %H:%M:%S")}: #{ChronicDuration.output(item[:count])}" }.join("\n\t") }"

top_5_timeouts = results[false].sort_by { |el| -el[:count] }.first(5)
puts "top 5 timeouts:\n\t#{top_5_timeouts.map { |item| "#{item[:time].strftime("%d/%m/%Y %H:%M:%S")}: #{ChronicDuration.output(item[:count])}" }.join("\n\t") }"

last_10__good_times = results[true].last(10)
puts "Last 10 without a timeout:\n\t#{last_10__good_times.map { |item| "#{item[:time].strftime("%d/%m/%Y %H:%M:%S")}: #{ChronicDuration.output(item[:count])}" }.join("\n\t") }"

last_10_timeouts = results[false].last(10)
puts "Last 10 timeouts:\n\t#{last_10_timeouts.map { |item| "#{item[:time].strftime("%d/%m/%Y %H:%M:%S")}: #{ChronicDuration.output(item[:count])}" }.join("\n\t") }"

puts "last ping: #{last_success ? "success" : "timed out"} for #{ChronicDuration.output(last_count)}"
