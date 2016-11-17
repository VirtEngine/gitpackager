require 'colorize'
require 'pkg/version'

module Pkg::Data
    include Pkg::Version

    CLOUD = "cloud".freeze

    def self.COMMON
        puts "=> Packaging: [#{COMMON} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:cyan).bold
        {
            package: COMMON,
            description: %Q[This is an empty package that creates the group and user, and the
        base directories  for #{BASIC[:product]}.],
            category: CLOUD
        }
    end

    def self.NILAVU
        puts "=> Packaging: [#{NILAVU} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold

        {
            package: NILAVU,
            description: %Q[Description: The dashboard for #{BASIC[:product]}.],
            category: 'cloud',

            deb_dependencies: "#{Pkg::Version::COMMON}",
            rpm_dependencies: "#{Pkg::Version::COMMON}",

            #The service name to start
            systemd_service: 'unicorn.service',
            upstart_service: 'unicorn'
        }.freeze
    end


    def self.GATEWAY
        puts "=> Packaging: [#{GATEWAY} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold

        {
            package: GATEWAY,
            description: %Q[Description: RESTful API gateway using HMAC authentication
            Vertice gateway connects to an opensource database ScyllaDB or,
            compatible cassandra 3.x for #{BASIC[:product]}.],
            category: CLOUD,

            dependencies: "#{Pkg::Version::COMMON}",

            git: 'https://github.com/megamsys/vertice_gateway',
            branch: '1.5',

            #The service name to start
            systemd_service: ' #{BASIC[:product].service',
            upstart_service: ' #{BASIC[:product]'
        }
    end

    def self.CADVISOR
        puts "=> Packaging: [#{CADVISOR} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold
        {
            package: CADVISOR,
            description: %Q[Description: Analyzes resource usage and performance characteristics of
                  running containers/machine for #{BASIC[:product]}.],
            category: CLOUD,

            dependencies: "#{Pkg::Version::COMMON}, cgroup-bin",

            # download the tar binary
            tar: 'https://s3.amazonaws.com/megam/cadvisor',

            #The service name to start
            systemd_service: 'cadvisor.service',
            upstart_service: 'cadvisor'
        }
    end

    def self.VERTICE
        puts "=> Packaging: [#{VERTICE} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold
        {
            package: VERTICE,
            description: %Q[Description: Core engine which provides scheduling,
          provisioning, realtime log streaming, events handling functions for #{BASIC[:product]}.
          Works on top of a messaging layer NSQ (nsq.io) with interface to an opensource database
          cassandra 3.7],
            category: CLOUD,
            dependencies: "#{COMMON}",
            #The git config differs for each of the project, hence we have them in the individual confs.
            #git_org is needed as golang uses namespace during compiling
            git: 'https://github.com/megamsys/vertice.git',
            git_org: 'github.com/megamsys',
            branch: '1.5',

            #The service name to start
            systemd_service: "#{VERTICE}.service",
            upstart_service: "#{VERTICE}"
        }
    end

    def self.GULPD
        puts "=> Packaging: [#{GULPD} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold
        {
            package: GULPD,
            description: %Q[Description: Agent which provides instrumentation,
          provisioning, realtime log streaming, events handling functions for #{BASIC[:product]}.
          Works on top of a messaging layer NSQ (nsq.io) with interface to an opensource database
          cassandra 3.7 or ScyllaDB 1.x.],
            category: CLOUD,
            dependencies: "#{COMMON}",

            #The git config differs for each of the project, hence we have them in the individual confs.
            #git_org is needed as golang uses namespace during compiling
            git: 'https://github.com/megamsys/gulp.git',
            git_org: 'github.com/megamsys',
            branch: '1.5',

            #The service name to start
            systemd_service: "#{GULPD}.service",
            upstart_service: "#{GULPD}",
            #Turn this flag on if you don't want to upload to cloud storage like S3
            skip_upload: false
        }
    end

    def self.NSQD
        puts "=> Packaging: [#{NSQD} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold
        {
            package: NSQD,
            description: %Q[Description: A realtime distributed messaging platform
          NSQ (nsq.io)  for #{BASIC[:product]}.],
            category: CLOUD,

            # download the tar binary
            tar: 'https://s3.amazonaws.com/bitly-downloads/nsq/nsq-0.3.8.linux-amd64.go1.6.2.tar.gz',

            #The service name to start
            systemd_nsqd_service: 'nsqd.service',
            systemd_nsqlookupd_service: 'nsqlookupd.service',
            systemd_nsqadmin_service: 'nsqadmin.service',

            upstart_nsqd_service: 'nsqd',
            upstart_nsqlookupd_service: 'nsqlookupd',
            upstart_nsqadmin_service: 'nsqadmin'
        }
    end

    def self.VNC
        puts "=> Packaging: [#{VNC} #{BASIC[:version]}:#{BASIC[:iteration]}]".colorize(:green).bold
        {
            package: VNC,
            description: %Q[Nodejs based VNC serverfor #{BASIC[:product]}],

            category: 'cloud',
            # download the tar binary
            git: 'https://github.com/megamsys/vnc_server.git',
            git_org: 'github.com/megamsys',
            branch: 'master',

            #The service name to start
            systemd_service: "#{VNC}.service",
            upstart_service: "#{VNC}"
        }
    end
end
