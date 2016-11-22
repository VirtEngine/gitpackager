module Pkg

  LIBDIR = File.expand_path(File.dirname(__FILE__))

  $:.unshift(LIBDIR) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(LIBDIR)

  require 'rake'
  require 'colorize'

  require 'pkg/common'
  require 'pkg/version'
  require 'pkg/util'

  require 'pkg/cloner'
  require 'pkg/builder'
  require 'pkg/config'
  require 'pkg/static/data'
  require 'pkg/utils'
  require 'pkg/scripter'
  require 'pkg/yaml_builder'
  require 'pkg/shipper'
  require 'pkg/tools'

  # Load configuration defaults
  Pkg::YamlBuilder.new.save
  Pkg::Config.load_defaults
  Pkg::Config.load_default_configs
end
