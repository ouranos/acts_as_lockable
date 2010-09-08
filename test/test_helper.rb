# =============================================================================
# Include the files required to test Engines.

# Load the default rails test helper - this will load the environment.
require File.dirname(__FILE__) + '/../../../../test/test_helper'

plugin_path = File::dirname(__FILE__) + '/..'

# set up the fixtures location to use your engine's fixtures
fixture_path = File.dirname(__FILE__)  + "/fixtures/"
ActiveSupport::TestCase.fixture_path = fixture_path
$LOAD_PATH.unshift(ActiveSupport::TestCase.fixture_path)
$LOAD_PATH.unshift(File.dirname(__FILE__))
# =============================================================================



config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])
load(File.dirname(__FILE__) + "/schema.rb")