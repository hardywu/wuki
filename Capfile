# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/bundler
#

require 'capistrano/rbenv'
require 'capistrano/puma'
require 'capistrano/bundler'

set :rbenv_type, :system # or :system, depends on your rbenv setup
set :rbenv_custom_path, '/opt/rbenv'
set :rbenv_ruby, '2.1.2'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
