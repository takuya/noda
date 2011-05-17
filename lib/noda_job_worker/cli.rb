require 'optparse'

module NodaJobWorker
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
        :port => '10001',
        :addr => 'localhost'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          This application is wonderful because...

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("--addr ADDR ", "job server address ."){|arg| options[:addr] = arg }
        opts.on("--port PORT ", "job server port "){|arg| options[:port] = arg }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end


      # do stuff
      # 
      require 'noda'
      require 'noda/job_worker'
      w= Noda::JobWorker.start_service( options[:addr], options[:port] )

    end
  end
end
