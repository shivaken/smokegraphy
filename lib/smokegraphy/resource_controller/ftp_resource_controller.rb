require 'net/ftptls'
require 'erb'
require 'tempfile'

module Smokegraphy

  class FtpResourceController < ResourceController

    def initialize(config)
      @config = config
    end

    def init
      @uploaded = []
      if (@config["deploy"] == "ftp" && $ftp == nil) then
        @@ftp = Net::FTPTLS.new(@config["ftp"]["server"],
                                @config["ftp"]["username"],
                                @config["ftp"]["password"]);
        @@ftp.passive = true
        @@ftp.debug_mode = false
      end      
    end
    
    def close
      @@ftp.close
    end

    def transfer_source_file(filename, testsuite, destname = nil)
      begin
        source = "source/#{testsuite}/#{filename}"
        destname ||= filename

        if File.exist?(source) then
          document_root = @config["http"]["document_root"]          

          temp = Tempfile.new("ftp_")
          File.open(temp.path, "w") { |out| out << ERB.new(File.new(source).read).result(binding) }
          @@ftp.put(temp.path, destname)
          temp.close          

          @uploaded << destname  if !(@uploaded.include? destname)
        else
          raise "no such file: #{source}"
        end
      rescue => evar
        raise "Failed to copy #{filename}: #{evar}"
      end
    end

    def add_execute_permission(filename)
      begin
        @@ftp.voidcmd("site chmod 755 #{filename}") 
      rescue => evar
        print "Failed to chmod #{filename}: #{evar}"
      end
    end
  
    def cleanup(filename = nil)
      if filename then
        files = @@ftp.nlst
        @@ftp.delete(filename) if files.include?(filename)
        @uploaded.delete filename
       else
         files = @@ftp.nlst
         @uploaded.each do |f|
          @@ftp.delete(f) if files.include?(f)
        end
      end
    end
  end
end
