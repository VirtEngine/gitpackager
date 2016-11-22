require 'rake'
require 'fileutils'
require 'colorize'
require 'pkg/scripter' #As this is called from one level down from Rakefile we do ../

module Pkg
    class Builder

        attr_accessor :distro_dir
        attr_accessor :distro_build_dir
        attr_accessor :date, :package

        def initialize(distro_dir, distro_build_dir, package, date = Time.now)
            @distro_dir = distro_dir
            @distro_build_dir = distro_build_dir
            @package = package
            @date = date
        end

        def exec
            make
            clone
            run
        end

        private

        def make(ls_dir = @distro_dir)
            puts "=> 1. Transform: erb - #{ls_dir} #{@distro_build_dir} ".colorize(:green).bold
            Rake::FileList[ls_dir + "/**"].each do |f|
            if File.file?(f)
                @scripter = Scripter.new(Pkg::Version::BASIC, @package,IO.read(f))
                @scripter.save(File.join("#{distro_build_dir}",File.basename(f, '.erb')))
            else
               if @distro_dir == "trusty"
                  Pkg::Util::File.mkdir_p("#{distro_build_dir}"+"/etc/init/")
                  Rake::FileList["#{f}/init/**"].each do |d|
                    @scripter = Scripter.new(Pkg::Version::BASIC, @package,IO.read(d))
                    @scripter.save(File.join("#{distro_build_dir}"+"/etc/init/",File.basename(d, '.erb')))
                  end
                else
                  Pkg::Util::File.mkdir_p("#{distro_build_dir}"+"/etc/systemd/system/")
                  Rake::FileList["#{f}/systemd/system/**"].each do |d|
                    @scripter = Scripter.new(Pkg::Version::BASIC, @package,IO.read(d))
                    @scripter.save(File.join("#{distro_build_dir}"+"/etc/systemd/system/",File.basename(d, '.erb')))
                  end
              end
          end

            end if File.exists?(@distro_dir)
            Dir.chdir @distro_build_dir
        end

        def clone
          Cloner.new(@package).clone
        end

        def run
            puts "=> 3. Execute: g - #{@distro_dir}".colorize(:green).bold
            if File.file?('./g')
                FileUtils.chmod 0755, './g'
                system './g'
            else
                puts "   ✘ skip g - #{@distro_dir}".colorize(:red)
            end
        end
    end
end
