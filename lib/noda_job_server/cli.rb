require 'optparse'
require 'noda'
require 'pp'

module NodaJobServer
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
        :addr => "localhost",
        :port => "10001",
        :daemon => false
      }
      mandatory_options = %w(  )

      parser = ARGV.options do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          This application is wonderful because...

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        
        
        opts.separator ""
        opts.on('-a','--addr IP_ADDR', 'bind adress'){ |v| options[:addr] = v }
        opts.on('-p','--port PORT', 'bind port'){ |v| options[:port] = v }
        opts.on('--daemon', 'run as daemon '){ |v| options[:daemon] = true }
        opts.on('--no-daemon', 'run in front * default'){ |v| options[:daemon] = false }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }


        opts.parse!(arguments)

        #if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          #stdout.puts opts; exit
        #end
      end
      
      if(options[:daemon]) then
        require 'daemons'
        Daemons.daemonize
      end

      s=Noda::JobServer.new( options[:addr],options[:port] )
      puts "starting job server at #{options[:addr]}:#{options[:port]} "
      sleep




      # do stuff
      
      
    end
  end
end