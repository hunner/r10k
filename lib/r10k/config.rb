require 'r10k/deployment'
require 'r10k/config/loader'

class R10K::Config

  attr_accessor :configfile

  def loaded?
    !(@config.nil?)
  end

  # Serve up the loaded config if it's already been loaded, otherwise try to
  # load a config in the current wd.
  def dump
    load_config unless @config
    @config
  end

  def setting(key)
    self.dump[key]
  end
  alias_method :[], :setting

  # Load and store a config file, and set relevant options
  #
  # @param [String] configfile The path to the YAML config file
  def load_config
    unless @configfile
      loader = R10K::Config::Loader.new
      @configfile = loader.search
    end
    File.open(@configfile) { |fh| @config = YAML.load(fh.read) }
    apply_config_settings
    @config
  end

  private

  # Apply config settings to the relevant classes after a config has been loaded.
  def apply_config_settings
    if @config[:cachedir]
      R10K::Synchro::Git.cache_root = @config[:cachedir]
    end
    @collection = R10K::Deployment::EnvironmentCollection.new(@config)
  end
end
