require 'colorize'
require 'pkg/common'
require 'pkg/config'

module Pkg
    class Shipper

        attr_accessor :distro

        def initialize(distro)
          @distro = distro
        end

        def ship
            puts "=> 4. Ship: distro - #{@distro}".colorize(:green).bold
            unless Pkg::Common.supported_os?
                puts "   ✘ skip ship".colorize(:red)
                return
            end
            Pkg::Util::File.install_files_into_dir(["./**/*.deb","./**/*.rpm", "./**/*.html"], Pkg::Config.ship_root)
        end
    end
end
