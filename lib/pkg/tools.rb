require 'fileutils'
require 'colorize'

module Pkg
    class Tools

        ## check if the following build tools are installed
        ## 1.5 [git, ruby, golang, npm, sbt]
        ## 2.0 [git, ruby, golang, npm, cargo]
        def check?
            git
            ruby
            golang
            npm
            cargo
        end

        private

        def is_there?(cmd)
            system cmd; result =$?.success?
        end

        def git
            unless is_there?("git version > /dev/null")
                puts "   ✘ git not installed"
                exit
            end
        end

        def ruby
            unless is_there?("ruby -v > /dev/null")
                puts "   ✘ ruby not installed"
                #exit
            end
        end

        def golang
          unless is_there?("go version > /dev/null")
              puts "   ✘ golang not installed"
          end
        end

        def npm
           unless is_there?("npm -v > /dev/null")
                puts "   ✘ npm not installed"
                #exit
            end
        end

        def cargo
            unless is_there?("cargo -V > /dev/null")
                puts "   ✘ cargo not installed"
                #exit
            end
        end
    end
end
