#!/usr/bin/env ruby

require 'test/unit'
require 'rubygems'
gem 'smokegraphy'

Test::Unit::AutoRunner.run(true, './tests')
