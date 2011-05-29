## Overview

Smokegraphy is a simple http access testing framework. That deploies test specific fixtures at setup, and remove them at teardown, and test must be executed with real http access. If you setup auto-deploying to use ftp, you can test not only localhost but also remote server. With Smokegraphy's test, you can find out miss configurations and/or network problems. Of course, Smokegraphy is useful to test webapps. 

This is compatible with only ruby-1.8, now.

## Install

    $ gem install smokegraphy

## Quick Start

Execute smokegraphy command as below. Then, directory 'simple-test' is created, and some teplates will be wrote. 

    $ smokegraphy new simple_test basic
    $ cd simple_test

Edit config.yaml, some path, http host name, and deploy method.

Then exec runner script. 

     $ ./runner.rb
	
## Writing a Test

Below is simplest code.

      class TestBasic < Smokegraphy::TestCase
        def test_index_html
	    simple_test
        end
      end

simple_test method will access to http://server/base_path/index.html, then checks status code and response body.


 * If you expected other response code, you can specify.

    simple_test(:code => 403)

 
 * If you want to check response header, use block.

 simple_test { |res| assert_equals("text/html", res["Content-Type"]) }

 * When you use block, default body check is disabled. So check it by your hand.

    simple_test(:request_header => { "Accept-Encoding" => 'gzip,deflate' } ) do |res| 
        def res.read(length = nil)
          self.read_body
        end
        assert_equal("gzip", res["Content-Encoding"])
        assert_equal(File.new("source/#{@suite}/#{@filename}").read, Zlib::GzipReader.new(res).read)
    end


## File Layout

Smokegraphy test should be placed as bellow

    testdir / tests    / test_basic.rb
            | source   / basic / **.html
            | expected / basic / **.html.result

 * Prepare fixture files (html,cgi or php) at source directory. 
 * Praepare result files at expected directory.
