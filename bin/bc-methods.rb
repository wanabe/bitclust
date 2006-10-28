#!/usr/bin/env ruby
#
# bc-methods.rb -- list all methods of existing rubys.
#
# This program is derived from bc-vdtb.rb, posted in
# [ruby-reference-manual:160] by sheepman.
#

require 'optparse'

def main
  @requires = []
  @verbose = false
  opts = OptionParser.new
  opts.banner = "Usage: #{File.basename($0, '.*')} [-r<lib>] <classname>"
  opts.on('-r LIB', 'Requires library LIB') {|lib|
    @requires.push lib
  }
  opts.on('-v', '--verbose', "Prints each ruby's version") {
    @verbose = true
  }
  opts.on('--help', 'Prints this message and quit.') {
    puts opts.help
    exit 0
  }
  begin
    opts.parse!(ARGV)
  rescue OptionParser::ParseError => err
    $stderr.puts err.message
    exit 1
  end
  unless ARGV.size == 1
    $stderr.puts "wrong number of arguments"
    $stderr.puts opts.help
    exit 1
  end
  vers, table = *get_method_table(ARGV[0])
  print_table vers, table
end

def get_method_table(classname)
  ENV.delete 'RUBYOPT'
  ENV.delete 'RUBYLIB'
  vers = []
  table = {}
  forall_ruby(ENV['PATH']) do |ruby, ver|
    puts "#{version_id(ver)}: #{ver}" if @verbose
    vers.push ver
    list_methods(ruby, classname).each do |m|
      (table[m] ||= {})[ver] = true
    end
  end
  return vers, table
end

def print_table(vers, table)
  hcols = [30, table.keys.map {|s| s.size }.max].max
  printf "%-#{hcols}s ", ''
  puts vers.map {|ver| version_id(ver) }.join(' ')
  table.keys.sort_by {|m| m_order(m) }.each do |m|
    printf "%-#{hcols}s ", m
    puts vers.map {|ver| table[m][ver] ? '  o' : '  -' }.join(' ')
  end
end

def version_id(ver)
  ver.split[1].tr('.', '')
end

ORDER = {
  '.'  => 1,
  '#'  => 2,
  '::' => 3
}

def m_order(m)
  m, t, c = *m.reverse.split(/(\#|\.|::)/, 2)
  [ORDER[t], m.reverse]
end

def list_methods(ruby, classname)
  req = @requires.map {|lib| "-r#{lib}" }.join(' ')
  `#{ruby} #{req} -e '
    #{classname}.singleton_methods(false).each do |m|
      puts "#{classname}.\#{m}"
    end
    #{classname}.instance_methods(false).each do |m|
      puts "#{classname}\\#\#{m}"
    end
    (#{classname}.constants - #{classname}.ancestors[1..-1].map {|c| c.constants }.flatten).each do |m|
      puts "#{classname}::\#{m}"
    end
  '`.split
end

def forall_ruby(path, &block)
  rubys(path)\
      .map {|ruby| [ruby, `#{ruby} --version`] }\
      .sort_by {|ruby, verstr| verstr }\
      .each(&block)
end

def rubys(path)
  parse_PATH(path).map {|bindir|
    Dir.glob("#{bindir}/ruby-[12].*").map {|path| File.basename(path) }
  }\
  .flatten.uniq + ['ruby']
end

def parse_PATH(str)
  str.split(':').map {|path| path.empty? ? '.' : path }
end

main
