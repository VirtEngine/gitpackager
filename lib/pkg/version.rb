require 'pkg/tools'

module Pkg
    module Version

        ### DOWNSTREAM FORKS: Please configure (STEPS 1, 2, 3) to whitelable builds

        ## check if  colorize gem is installed.
        unless Gem::Specification::find_all_by_name('colorize').any?
            puts "   ✘ gem colorize not installed"
            puts 'Run "bundle install"'
            exit
        end

        Pkg::Tools.new.check?

        ## All of these can be loaded using a YAMLLoader (build_data.yml)
        ## Default operation system supported
        SUPPORTED_OS =  { os: %w(trusty xenial centos7)}

        ## STEP 1: Configure directories
        # change the name to your own downstream fork.
        # eg:
         HOME    = "/usr/share/detio"
         LIBHOME = "/var/lib/detio"
         LOGHOME = "/var/log/detio"
         RUNHOME = "/var/run/detio"
     #   HOME     = "/usr/share/megam"
     #   LIBHOME  = "/var/lib/megam"
      #  LOGHOME  = "/var/log/megam"
       # RUNHOME  = "/var/run/megam"

        # STEP 2: Configure basic fields used across the packager
        # change the name to your own downstream fork.
        # eg:
        # origin: virtengine
        # product: VirtEngine
        # product_prefix: virtengine
        BASIC = {
            origin:         "virtengine",
            product:        "VirtEngine".freeze,
            product_prefix: "virtengine".freeze,
            version:        "1.5.1".freeze,
            iteration:      "1".freeze,
            license:        "MIT".freeze,
            home:           "#{HOME}",
            libhome:        "#{LIBHOME}",
            loghome:        "#{LOGHOME}",
            runhome:        "#{RUNHOME}",
            vendor:         "DET.io".freeze,
            maintainer:     "VirtEngine Humans <hello@virtengine.com>".freeze,
            url:            "https://docs.virtengine.com".freeze
        }

        # *OPTIONAL*
        # STEP 3: Configure packages names to your choice
        COMMON    = BASIC[:product_prefix] + "common".freeze
        NILAVU    = BASIC[:product_prefix] + "nilavu".freeze
        GATEWAY   = BASIC[:product_prefix] + "gateway".freeze
        NSQD      = "nsqd".freeze
        CADVISOR  = "cadvisor".freeze
        VERTICE   = BASIC[:product_prefix].freeze
        GULPD     = BASIC[:product_prefix] + "gulpd".freeze
        VNC       = BASIC[:product_prefix] + "vnc".freeze
    end
end
