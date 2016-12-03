#!/usr/bin/env ruby
# http://stackoverflow.com/questions/4244611/pass-variables-to-ruby-script-via-command-line
# https://stelfox.net/blog/2012/12/rubys-option-parser-a-more-complete-example/
#
# system "ant clean all unittests -Dtestclasses.extensions=${EXT0}"
# 
# -a --all   run all tests in all extensions
# -b --both  run both integration/unit tests in a list of extensions
# -e --ext   run unit tests in a list of extensions
# -u --unit  run unit tests in a list of packages

#!/usr/bin/env ruby
#
# This file provides an example of creating a command line application with a
# wide variety of command line options, parsing and the like as well as global
# configuration singleton that can be relied on throughout a program.
#
# This entire setup lives within the "Example" module. These are really common
# names and it would be a shame to override required functionality in other code
# that wasn't properly namespaced.
#
# @author Sam Stelfox
# @see https://stelfox.net/blog/2012/12/rubys-option-parser-a-more-complete-example/
#
require_relative 'HybrisJunit'


cfg_file = "junit_cfg.yml"
if File.exists?(cfg_file)
  HybrisJUnit::Configuration.load(cfg_file)
end

HybrisJUnit::ConfigurationParser.parse(ARGV)
HybrisJUnit::Configuration.validate!

if HybrisJUnit::Configuration.verbose
  require "json"
  puts JSON.pretty_generate(HybrisJUnit::Configuration.to_hash)
end

HybrisJUnit::Configuration.run!

if $?.exitstatus > 0
  puts "I failed to run ant"
end