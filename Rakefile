require "bundler/gem_tasks"

$: << File.dirname(__FILE__)

ROOT_DIR         = File.dirname(__FILE__).freeze
BUILD_DIR        = File.join(ROOT_DIR, 'build').freeze

SHELL_DIR          = File.join(ROOT_DIR, 'shell').freeze
SHELL_LAYOUTS_DIR  = File.join(SHELL_DIR, 'layouts').freeze
SHELL_VIEWS_DIR    = File.join(SHELL_DIR, 'views').freeze
SHELL_PARTIALS_DIR = File.join(SHELL_DIR, 'partials').freeze
SHELL_JS_DIR       = File.join(SHELL_DIR, 'support').freeze

FEATURES_DIR = File.join(ROOT_DIR, 'features').freeze
FEATURE_RESULTS_DIR = File.join(ROOT_DIR, 'results').freeze


KERNEL_DIR          = File.join(ROOT_DIR, 'kernel').freeze
KERNEL_JS_DIR       = File.join(KERNEL_DIR, 'app').freeze
KERNEL_SPEC_DIR     = File.join(KERNEL_DIR, 'spec').freeze

BUILD_CORE_DIR         = File.join(BUILD_DIR, 'core').freeze
BUILD_CORE_KERNEL_DIR  = File.join(BUILD_CORE_DIR, 'kernel').freeze
BUILD_CORE_CSS_DIR     = File.join(BUILD_CORE_DIR, 'stylesheets').freeze

ASSETS_DIR       = File.join(ROOT_DIR, 'assets').freeze
ASSETS_IMG_DIR   = File.join(ASSETS_DIR, 'images').freeze
ASSETS_LIB_DIR   = File.join(ASSETS_DIR, 'lib').freeze
ASSETS_CSS_DIR   = File.join(ASSETS_DIR, 'stylesheets').freeze
ASSETS_FONTS_DIR = File.join(ASSETS_DIR, 'fonts').freeze

APACHE_DIR      = File.join(ROOT_DIR, 'web', 'apache').freeze
WEB_DIR         = File.join(ROOT_DIR, 'web').freeze
APACHE_LOGS_DIR = File.join(APACHE_DIR, 'logs').freeze

CONFIG_DIR          = File.join(ROOT_DIR, 'config').freeze
CONFIG_YAML         = File.join(CONFIG_DIR, 'environments.yml').freeze
CONFIG_TEMPLATE_DIR = File.join(CONFIG_DIR, 'templates').freeze
CONFIG_RESULT_DIR   = File.join(CONFIG_DIR, 'result').freeze
directory CONFIG_RESULT_DIR

CONFIG = {}

[:ios, :droid, :web].each do |os|
  CONFIG[os] = {}
  CONFIG[os][:root]   = File.join(ROOT_DIR, os.to_s)
  CONFIG[os][:public] = if os == :ios
                          File.join(CONFIG[os][:root], 'Shopping.Booking', 'ShoppingResources', 'public').freeze
                        else
                          if os == :droid
                            File.join(CONFIG[os][:root], app_name, 'assets', 'hybrid').freeze
                          else
                            File.join(CONFIG[os][:root], 'public').freeze
                          end
                        end
  CONFIG[os][:html]   = File.join(CONFIG[os][:public], 'views').freeze
  CONFIG[os][:assets] = if os == :ios
                          File.join(CONFIG[os][:public], 'assets').freeze
                        else
                          CONFIG[os][:public]
                        end
  CONFIG[os][:imgs]   = File.join(CONFIG[os][:assets], 'images').freeze
  CONFIG[os][:js]     = File.join(CONFIG[os][:assets], 'scripts').freeze
  CONFIG[os][:css]    = File.join(CONFIG[os][:assets], 'styles').freeze
  CONFIG[os][:fonts]  = File.join(CONFIG[os][:assets], 'fonts').freeze
  CONFIG[os][:layout] = File.join(CONFIG[os][:root], "app", "views").freeze

  directory CONFIG[os][:public]
  directory CONFIG[os][:html]
  directory CONFIG[os][:assets]
  directory CONFIG[os][:imgs]
  directory CONFIG[os][:js]
  directory CONFIG[os][:css]
  directory CONFIG[os][:fonts]
end

CONFIG[:ios][:project_name] = app_name
CONFIG[:ios][:app_dir]      = File.join(CONFIG[:ios][:root], 'Source', app_name)
CONFIG[:ios][:cucumber]     = FEATURES_DIR

directory BUILD_CORE_DIR
directory BUILD_CORE_CSS_DIR
directory BUILD_CORE_KERNEL_DIR

require 'task_support/assets'
require 'task_support/calatrava_kernel'
require 'task_support/haml'
require 'task_support/apache'
require 'task_support/artifact'
require 'task_support/configuration'

Dir.glob('tasks/*.rake').each { |r| import r }

desc "Clean all directories"
task :clean => ["core:clean", "ios:clean", "bb:clean", "web:clean", "artifact:clean", "droid:clean"] do
  rm_rf BUILD_DIR
end
