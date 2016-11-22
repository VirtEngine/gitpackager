module Pkg::Params

    BUILD_PARAMS = [:distro,
        :name,
        :project_root,
        :packaging_repo,
        :packaging_release,
        :packaging_iteration,
        :git_release,
        :ship_root,
    :gpg_key]

    def self.ARGVS
        return {} if ARGV.length <= 2

        cut_args = ARGV.slice(1..-1).map {|s| s.split('=')}.flatten

        Hash[*cut_args].map { |k,v| [k.to_sym, v] }.to_h
    end

end
