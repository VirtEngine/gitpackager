module Pkg
    module Common
        attr_accessor :os

        ## All of these can be loaded using a YAMLLoader (build_data.yml)
        ## Default operation system supported
        SUPPORTED_OS =  { os: %w(trusty xenial centos7)}

        ### The build directory
        BUILD  = "build"

        
        # set the ditro and the distro build directory if its the supported os.
        def self.distro(os)
            @os = os
        end

        def self.distro_dir
          @os
        end

        def self.build_dir
            BUILD
        end

        def self.distro_build_dir
            (BUILD + "/" + self.distro_dir) if self.supported_os?
        end

        private

        def self.supported_os?
            raise "=> Unsupported OS: #{@os}" unless SUPPORTED_OS[:os].include? @os
            true
        end
    end
end
