# 
# This file provides the module so that Hybris unit tests can be
# run via configurations in a YML file.
# 
# @author Alan Wong
# @see https://stelfox.net/blog/2012/12/rubys-option-parser-a-more-complete-example/
#
require 'optparse'
require 'singleton'
require 'yaml'

module HybrisJUnit
  # Defines the available configuration options for the configuration
  ConfigurationStruct = Struct.new(:both, :unit, :web, :package, :required, :all, :test, :all_extensions, :all_packages, :verbose, :webExtensions, :enabled)

  class Configuration
    include Singleton

    # Initialize the configuration and set defaults:
    @@config = ConfigurationStruct.new

    # This is where the defaults are being set
    # @@config.enum = :one
    @@config.both = []
    @@config.unit = []
    @@config.web = []
    @@config.package = []
    @@config.all_extensions = {}
    @@config.all_packages = {}
    @@config.all = nil
    @@config.test = nil
    @@config.required = "vacuously-true"
    @@config.verbose = false
    @@config.enabled = true
    @@config.webExtensions = []

    def self.config
      yield(@@config) if block_given?
      @@config
    end

    # Loads a YAML configuration file and sets each of the configuration values to
    # whats in the file.
    def self.load(file)
      YAML::load_file(file).each do |key, value|
        self.send("#{key}=", value)
      end
    end

    # This provides an easy way to dump the configuration as a hash
    def self.to_hash
      Hash[@@config.each_pair.to_a]
    end

    # Pass any other calls (most likely attribute setters/getters on to the
    # configuration as a way to easily set/get attribute values 
    def self.method_missing(method, *args, &block)
      if @@config.respond_to?(method)
        @@config.send(method, *args, &block)
      else
        raise NoMethodError
      end
    end

    # Handles validating the configuration that has been loaded/configured
    def self.validate!
      valid = true

      valid = false if Configuration.required.nil?

      raise ArgumentError unless valid
    end

    def self.includesWebTests(extensions)
      _intersect = extensions & self.webExtensions
      if self.verbose
        puts "intersection of selected extensions with web extensions: " + _intersect.join(",")
      end
      !_intersect.empty?
    end

    def self.run_all!
      _selection = self.all_extensions
      _selectionJoin = _selection.join(",")
      if self.verbose
        puts "should execute all tests in all extensions: " + _selectionJoin
        if self.includesWebTests(_selection)
          puts "some of the selected extensions include web/testsrc"
        end
      end
      self.run_impl!("ant clean all yunitinit alltests -Dtestclasses.extensions=" + _selectionJoin)
    end

    def self.select_extensions(indices)
      _extensions = indices.map { |a| a.to_i }
      _selection = _extensions.map { |b| self.all_extensions[b] }.compact
    end

    def self.select_packages(indices)
      _packages = indices.map { |a| a.to_i }
      _selection = _packages.map { |b| self.all_packages[b] }.compact
    end

    def self.run_both!
      _selection = self.select_extensions(self.both)
      _selectionJoin = _selection.join(",")
      if self.verbose
        puts "should execute both integration/unit tests on extensions: " + _selectionJoin
        if self.includesWebTests(_selection)
          puts "some of the selected extensions include web/testsrc"
        end
      end
      self.run_impl!("ant clean all yunitinit alltests -Dtestclasses.extensions=" + _selectionJoin)
    end

    def self.run_web_extensions!
      _selection = self.select_extensions(self.web)
      _selectionJoin = _selection.join(",")
      if self.verbose
        puts "should execute both integration/unit tests on web extensions: " + _selectionJoin
        if self.includesWebTests(_selection)
          puts "some of the selected extensions include web/testsrc"
        end
      end
      _selection = self.webExtensions
      _webJoin = self.webExtensions.join(",")
      self.run_impl!("ant clean all yunitinit alltests -Dtestclasses.web=true -Dtestclasses.extensions=" + _webJoin)
    end

    def self.run_unit_extensions!
      _selection = self.select_extensions(self.unit)
      _selectionJoin = _selection.join(",")
      if self.verbose
        puts "should execute unit tests on extensions: " + _selectionJoin
        if self.includesWebTests(_selection)
          puts "some of the selected extensions include web/testsrc"
        end
      end
      self.run_impl!("ant clean all unittests -Dtestclasses.extensions=" + _selectionJoin)
    end

    def self.run_unit_packages!
      _selection = []
      if self.package.any?
        _selection = self.select_packages(self.package)
      else
        _selection = self.all_packages
      end
      _selectionJoin = _selection.join(",")
      if self.verbose
        puts "should execute unit tests on package: " + _selectionJoin
      end
      self.run_impl!("ant clean all unittests -Dtestclasses.packages=" + _selectionJoin)
    end

    def self.run_impl!(_ant_options)
      if self.verbose
        puts _ant_options
      end
      if self.enabled
        system _ant_options
      end
    end

    def self.run!
      puts "==================================="
      puts "Running ant .... "
      puts "==================================="


      if self.test
        run_unit_packages!
      elsif self.all
        run_all!
      else
        if self.both.any? && self.all_extensions.any?
          run_both!
        elsif self.web.any? && self.all_extensions.any? && self.webExtensions.any?
          run_web_extensions!
        elsif self.unit.any? && self.all_extensions.any?
          run_unit_extensions!
        elsif self.package.any? && self.all_packages.any?
          run_unit_packages!
        else
          if self.verbose
            puts "Nothing to do"
          end
        end
      end
    end

  end

  class ConfigurationParser
    def self.title
      "Hybris JUNIT CLI Runner v1.0.0"
    end
    def self.parse(args)
      opts = OptionParser.new do |parser|
        parser.separator title
        parser.separator ""
        parser.separator "Specific options:"

        #parser.on("-e", "--enum ENUM", [:one, :two, :three], "This field requires one of a set of predefined values be", "set. If wrapped in brackets this option can be set to nil.") do |setting|
        #  Configuration.enum = setting
        #end

        parser.on("-b", "--both 0,1,...", Array, "Run both integration/unit tests on a list of extensions defined in junit_cfg.yml", "as an array under the property called all_extensions.", "Extensions to run are selected by a 0-based index.") do |setting|
          Configuration.both = setting
        end

        parser.on("-w", "--web 0,1,...", Array, "Run both integration/unit tests on a list of web extensions defined in junit_cfg.yml", "as an array under the property called all_extensions as well as in webExtensions.", "Extensions to run are selected by a 0-based index.") do |setting|
          Configuration.web = setting
        end

        parser.on("-u", "--unit 0,1,...", Array, "Run unit tests on a list of extensions defined in junit_cfg.yml", "as an array under the property called all_extensions", "Extensions to run are selected by a 0-based index.") do |setting|
          Configuration.unit = setting
        end

        parser.on("-p", "--package 0,1,...", Array, "Run unit tests on a list of packages defined in junit_cfg.yml", "as an array under the property called all_packages.","Packages to run are selected by a 0-based index.") do |setting|
          Configuration.package = setting
        end

        parser.on("-v", "--[no-]verbose", "This boolean flag sets verbosity to either true or false.") do |setting|
          Configuration.verbose = setting
        end

        parser.on("--[no-]enabled", "This boolean flag enables whether ant is run") do |setting|
          Configuration.enabled = setting
        end

        parser.on("-t","--test", "Run all tests in all packages defined in junit_cfg.yml", "as an array under the property called all_packages") do |setting|
          Configuration.test = setting
          Configuration.all = false
        end

        parser.on("-a","--all", "Run all tests in all extensions defined in junit_cfg.yml", "as an array under the property called all_extensions") do |setting|
          Configuration.all = setting
          Configuration.test = false
        end

        # parser.on("-r", "--required STR", "This command requires a string to be passed to it.") do |setting|
        #  Configuration.required = setting
        # end

        parser.on_tail("-h", "--help", "--usage", "Show this usage message and quit.") do |setting|
          puts parser.help
          exit
        end

        parser.on_tail("--version", "Show version information about this program and quit.") do
          puts self.title
          exit
        end
      end

      opts.parse!(args)
    end
  end
end
