# Utils

# taken from https://github.com/grosser/parallel/blob/master/lib/parallel.rb#L114
def processor_count
  case RbConfig::CONFIG['host_os']
    when /darwin9/
      `hwprefs cpu_count`.to_i
    when /darwin/
      (`which hwprefs` != '' ? `hwprefs thread_count` : `sysctl -n hw.ncpu`).to_i
    when /linux|cygwin/
      `grep -c ^processor /proc/cpuinfo`.to_i
    when /(net|open|free)bsd/
      `sysctl -n hw.ncpu`.to_i
    when /mswin|mingw/
      require 'win32ole'
      wmi = WIN32OLE.connect("winmgmts://")
      cpu = wmi.ExecQuery("select NumberOfLogicalProcessors from Win32_Processor")
      cpu.to_enum.first.NumberOfLogicalProcessors
    when /solaris2/
      `psrinfo -p`.to_i # this is physical cpus afaik
    else
      $stderr.puts "Unknown architecture ( #{RbConfig::CONFIG["host_os"]} ) assuming one processor."
      1
  end
end

# Get system load average
loadavg = `w|grep 'load averages:'`.match(/load averages: [\d\.]+ [\d\.]+ ([\d\.]+)/)[1].to_i
puts "Current Load Average: #{loadavg}"

# Get num CPUs
current_cpus = processor_count
puts "Current CPUs: #{current_cpus}"

# Get num CPUs used by BOINC
CC_CONFIGS = [
  '/var/lib/boinc-client/cc_config.xml',
  '/Library/Application Support/BOINC Data/cc_config.xml'
]
cc_config_path = nil
CC_CONFIGS.each do |path|
  if File.exists? path
    cc_config_path = path
    break
  end
end
raise "cc_config not found within #{CC_CONFIGS}" unless File.exists? cc_config_path

current_ncpus = File.read(cc_config_path).match(/<ncpus>(\d+)<\/ncpus>/)[1].to_i
puts "Current BOINC CPUs: #{current_ncpus}"
target_ncpus = current_ncpus

# Optimize num CPUs used by BOINC
if loadavg > (current_cpus + 1) && target_ncpus > 0
  # Decrease BOINC CPUs
  target_ncpus -= 1
  puts 'Decreasing BOINC ncpus'
elsif loadavg < (current_cpus + 1) && target_ncpus < current_cpus
  target_ncpus += 1
  puts 'Increasing BOINC ncpus'
else
  puts 'Nothing to do here'
end

# Update BOINC CC config
if current_ncpus != target_ncpus
  `sed -i.bu 's/<ncpus>#{current_ncpus}</ncpus>/<ncpus>#{target_ncpus}</ncpus>/g' "#{cc_config_path}"`

  `cd #{File.dirname cc_config_path} && boinccmd --read_cc_config`

  # Validate
  changed_ncpus = File.read(cc_config_path).match(/<ncpus>(\d+)<\/ncpus>/)[1]
  puts "New BOINC CPUs: #{changed_ncpus}"
end

