require 'fileutils'
require 'erb'

module Smokegraphy

  class FileResourceController < ResourceController

    def initialize(config)
      @config = config
    end

    def init
      @uploaded = []
    end

    def transfer_source_file(filename, testsuite, destname = nil)

      begin
        source = "source/#{testsuite}/#{filename}"
        destname ||= filename
        destfile_path = "#{@config["file"]["path"]}/#{destname}"

        if File.exist?(source) then
          document_root = @config["http"]["document_root"]
          erb = ERB.new(File.new(source).read)

          File.open(destfile_path, "w") { |out| out << erb.result(binding) }
          @uploaded << destfile_path if !(@uploaded.include? destfile_path)

        else
          raise "no such file: #{source}"
        end

      rescue => evar
        raise "Failed to copy #{source}: #{evar}"
      end
    end

    def add_execute_permission(filename)
      begin
        File.chmod 0755, "#{@config["file"]["path"]}/#{filename}"
      rescue => evar
        print "Failed to chmod #{filename}: #{evar}"
      end
    end

    def cleanup(filename = nil)
      if filename then
        filepath = "#{@config["file"]["path"]}/#{filename}"
        FileUtils.rm(filepath, :force => true)
        @uploaded.delete filepath
      else
        @uploaded.each do |f|
          FileUtils.rm(f, :force => true)
        end
      end
    end
  end
end
