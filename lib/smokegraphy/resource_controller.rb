module Smokegraphy

  class ResourceController
    
    def ResourceController.build(config)
      case (config["deploy"])
      when "ftp"
        FtpResourceController.new(config)
      when "file"
        FileResourceController.new(config)
      else
        ResourceController.new(config)
      end
    end
  
    def initialize(config)
      @config = config
    end

    # initialize
    #
    # must be called once before running tests
    def init
    end

    # close
    #
    # must be called once after all tests.
    def close
    end

    def transfer_source_file(filename, testsuite, destname = nil)
    end

    def add_execute_permission(filename)
    end

    def cleanup(filename = nil)
    end
  end

  require 'smokegraphy/resource_controller/ftp_resource_controller'
  require 'smokegraphy/resource_controller/file_resource_controller'
end

