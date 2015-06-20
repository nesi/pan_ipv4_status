#!/usr/local/bin/ruby
require 'open3'
#from: fping -c 5 -q -f filename 
#Producing: 
#wikk021               : xmt/rcv/%loss = 5/5/0%, min/avg/max = 3.53/4.97/7.26
#wikk-b18-wikk-b19-wds    : xmt/rcv/%loss = 5/0/100%
#external4                : xmt/rcv/%loss = 5/4/20%, min/avg/max = 300/410/521
# @param source [String] fping stdout and stderr output
# @param output [Array]  hostname, state pairs in an Array
def parse(source, output)
  source.each_line do |line|
    words = line.strip.squeeze(' \t').split(/[ \t\/]/)
    if words && words[0] != "ICMP"
      #words.each { |x| print "\"#{x}\"\t" }
      #print "\n"
      if(words[8] == "100%") #total loss
        output << [words[0],'fault']
      elsif(words[8] != "0%,") #partial loss
        output << [words[0],'degraded']
      else 
        output << [words[0],'ok']
      end
    end
  end
end

#Converts the output of fping -c to json files for our web status pages
# @param fd [File] Open File, ready for writing to
# @param source [String] the Stdout and Stderr from fping -c
def to_json(fd, source)
  result_set = []
  fd.puts "{", "  'datetime': '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'," , "  'state': {"
  parse(source, result_set)
  result_set.each { |x| fd.puts "    '#{x[0]}': '#{x[1]}'," }
  fd.puts "    'end': ''", "  }\n}"
end

out_err, st  = Open3.capture2e('/usr/bin/fping','-c', '5', '-q', '-f', ARGV[0])

File.open(ARGV[1], 'w') do |fd|
  to_json(fd,out_err)
end
