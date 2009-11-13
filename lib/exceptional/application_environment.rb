require 'digest/md5'

module Exceptional
  class ApplicationEnvironment
    def self.to_hash
      hash = {
        'client' => {
          'name' => Exceptional::CLIENT_NAME,
          'version' => Exceptional::VERSION,
          'protocol_version' => Exceptional::PROTOCOL_VERSION
        },
        'application_environment' => {
          'environment' => environment,
          'env' => extract_environment(ENV),
          'host' => get_hostname,
          'run_as_user' => get_username,
          'application_root_directory' => application_root,
          'language' => 'ruby',
          'language_version' => "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} #{RUBY_RELEASE_DATE} #{RUBY_PLATFORM}",
          'framework' => framework,
          'libraries_loaded' => libraries_loaded
        }
      }
      hash
    end

    def self.framework
      defined?(RAILS_ENV) ? "rails" : nil
    end

    def self.environment
      Config.application_environment
    end

    def self.application_root
      Config.application_root
    end

    def self.extract_environment(env)
      env.reject{|k, v| k =~ /^HTTP_/}
    end

    def self.get_hostname
      require 'socket' unless defined?(Socket)
      Socket.gethostname
    rescue
      'UNKNOWN'
    end

    def self.get_username
      ENV['LOGNAME'] || ENV['USER'] || ENV['USERNAME'] || ENV['APACHE_RUN_USER'] || 'UNKNOWN'
    end

    def self.libraries_loaded
      begin
        return Hash[*Gem.loaded_specs.map{|name, gem_specification| [name, gem_specification.version.to_s]}.flatten]
      rescue
      end
      {}
    end
  end
end