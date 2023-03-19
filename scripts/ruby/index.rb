require 'optparse'
require 'colorize'

def read_file(filename)
  file = File.open(filename, 'r')
  lines = file.readlines.map(&:chomp)
  file.close
  return lines
end

OptionParser.new do |parser|
  parser.on('-s', 'scan a list of address') do
    addresses = read_file('hosts')
    addresses.each do |address|
      result = `ping -c 1 -W 2 #{address}`
      if $?.exitstatus == 0
        texto = "#{address} UP"
        puts texto.sub('UP', 'UP'.green)
      else
        texto = "#{address} DOWN"
        puts texto.sub('DOWN', 'DOWN'.red)
      end
    end
  end
  
  parser.on('-e', '--exec COMMAND', 'executes a command on a set of machines') do |command|
    addresses = read_file('hosts')
    addresses.each do |address|
      result = `ping -c 1 -W 2 #{address}`
      if $?.exitstatus == 0
        result = `ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no -qt -i "/home/hec7or/.ssh/id_ed25519" a798095@#{address} #{command}`
        puts result
      end
    end
  end
end.parse!
