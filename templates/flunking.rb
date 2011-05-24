#!/usr/bin/env ruby

require 'smokegraphy'

class Test<%= testname.capitalize %> < Smokegraphy::TestCase

  def test_index_html
    simple_test
  end
end
