require 'erb'
require 'colorize'
require 'pathname'

module Pkg
    class YamlBuilder
        include ERB::Util

        attr_accessor :basic
        attr_accessor :package
        attr_accessor :date
        attr_accessor :template
        attr_accessor :out_path

        def initialize
            @basic    = ""
            @package  = ""
            @date     = ""
            erb_path = Pathname(File.expand_path(File.dirname(__FILE__))).to_s +  "/../../build_defaults.yaml.erb"

            @out_path = Pathname(File.expand_path(File.dirname(__FILE__))).to_s +  "/../../build_defaults.yaml"

            @template = IO.read(erb_path)
        end

        def render
              ERB.new(@template).result(binding)
        end

        def save
            FileUtils.rm(@out_path) if Pkg::Util::File.exists?(@out_path)

            File.open(@out_path, 'w+') do |f|
                puts "   ✔ #{f.path}".colorize(:blue)
                f.write(render)
            end
        end
    end
end
