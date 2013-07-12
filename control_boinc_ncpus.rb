# Get system load average

current_loadavg = `w|grep 'load averages:'`.match(/load averages: [\d\.]+ [\d\.]+ ([\d\.]+)/)[1]

puts puts "Current Load Average: #{current_loadavg}"

# Get num CPUs used by BOINC
