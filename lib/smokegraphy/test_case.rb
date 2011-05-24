require 'yaml'
require 'net/http'
require 'test/unit'
require 'logger'
require 'smokegraphy/resource_controller'

module Smokegraphy

  class TestCase < Test::Unit::TestCase

    def self.suite
      suite = super
      
      @@config = YAML.load_file('config.yaml')
      @@rc = ResourceController.build(@@config)
      @@http_server = @@config["http"]["server"]

      def suite.run(*args)
        if (name != "Smokegraphy::TestCase") then
          @@rc.init
          super
          @@rc.close
        end
      end

      suite
    end

    def setup
      @log = Logger.new("test.log")
      @log.datetime_format = "%Y-%m-%d %H:%M:%S"

      name.match(/(.*)\((.*)\)/)
      @testname = $1
      @suite = $2.gsub(/([A-Z])/, "_\\1").downcase.gsub(/^_/,"").gsub(/^test_/,"")
      @filename = @testname.gsub(/test_(.*)_([^_]*)$/, "\\1.\\2").gsub(/_html/,".html")
      prepare
    end

    def teardown
      @@rc.cleanup
    end

    def prepare
      @@rc.transfer_source_file(@filename, @suite)
      suffix = @filename.gsub(/[^\.]*\.([a-z0-9]*)/, "\\1")
      @@rc.add_execute_permission(@filename) if suffix == "cgi"

      # no warning
      begin
        @@rc.transfer_source_file("#{@filename.gsub(/\./, "_")}.htaccess", @suite, ".htaccess")
      rescue => ever
      end
    end

    def deploy(filename)
      @@rc.transfer_source_file(filename, @suite)
    end

    def simple_test(options = {})

      @@rc.transfer_source_file("#{options[:htaccess]}.htaccess", @suite, ".htaccess") if (options[:htaccess])
      
      begin

        # prepare request object
        uri = options[:request_uri] ? options[:request_uri] : "/#{@filename}"
        uri << "?%s" % options[:query].map { |k,v| "%s=%s" % [k,v] }.sort.join("&") if options[:query]

        if (options[:method] == :post) then
          req = Net::HTTP::Post.new(uri)
          req.body = options[:post_data].map { |k,v| "%s=%s" % [k,v] }.sort.join("&") if options[:post_data]
          req["Request-Method"] = "POST"
          req["Content-Length"] = req.body.size
        else
          req = Net::HTTP::Get.new(uri)
        end

        # setup request header       
        options[:request_header].each {|k,v| req[k] = v } if (options[:request_header] != nil)
        req["Host"] = @@http_server
        Net::HTTP.start(@@http_server, 80) do |http|

          # execute http access
          res = http.request(req)

          # check status code.
          assert_equal(options[:code] ? options[:code].to_s : "200", res.code,
                       "status code check failed. [filename: #{@filename}]")

          # check body
          if (res.code == "200" && (!block_given? || options[:expected] == true)) then
            expected = "expected/#{@suite}/#{@filename.gsub(/\./, "_")}.result"
            assert_equal(File.new(File.exist?(expected) ? expected : "source/#{@suite}/#{@filename}").read, res.body) 
          end

          # block process
          yield res if block_given?

        end

      rescue => evar
        @log.info(evar)
        result = "Failed"

      else
        result = "Success"

      ensure
        @log.info("test #{@suite}:#{@filename}: #{result} [#{options.keys.join(", ")}]")
        
        @@rc.cleanup(".htaccess") if options[:htaccess]

      end

      raise evar  if (evar) 
    end

  end
end
