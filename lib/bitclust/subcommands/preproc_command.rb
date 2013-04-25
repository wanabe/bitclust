require 'pathname'
require 'optparse'

require 'bitclust/rrdparser'

module BitClust::Subcommands
  class PreprocCommand < BitClust::Subcommand

    def initialize
      super
      @params = { "version" => "2.0.0" }
      @parser.banner = "Usage: #{File.basename($0, '.*')} <file>..."
      @parser.on('--param=KVPAIR', 'Set parameter by key/value pair.') {|pair|
        key, value = pair.split('=', 2)
        params[key] = value
      }
    end

    def exec(argv, options)
      argv.each do |path|
        File.open(path) {|file|
          BitClust::Preprocessor.wrap(file, @params).each do |line|
            puts line
          end
        }
      end
    rescue BitClust::WriterError => err
      $stderr.puts err.message
      exit 1
    end

  end
end
