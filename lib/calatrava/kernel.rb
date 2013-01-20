require 'rake'

module Calatrava

  class Kernel
    include Rake::DSL

    def initialize(root)
      @path = root
    end

    def features
      Dir.chdir @path do
        Dir['kernel/app/*'].select { |n| File.directory? n }.collect do |n|
          {
            :name => File.basename(n),
            :coffee => Dir["#{n}/*.coffee"],
            :js => Dir["#{n}/*.js"]
          }
        end
      end
    end

    def js_files
      Dir.chdir @path do
        Dir["kernel/app/*.js"] + Dir["kernel/plugins/*.js"]
      end
    end

    def coffee_files
      Dir.chdir @path do
        Dir["kernel/app/*.coffee"] + Dir["kernel/plugins/*.coffee"]
      end
    end

    def coffee_path
      (['app', 'app/plugins'] + features.collect { |m| "app/#{m[:name]}" }).join(':')
    end

    def prepare_for_features
      sh "ln -sFfh kernel/features/step_definitions/ features/step_definitions"
      sh "ln -sFfh kernel/features/support/ features/support"
    end

    def node_path_for_features
      "#{coffee_path}:features/support:../assets/lib:features/step_definitions:../features/testdata"
    end

    def install_tasks
      file '.node_updated' => 'package.json' do
        sh "npm install && touch .node_updated"
      end

      desc "Run jasmine test. If specs not given in argument, runs all test"
      task :spec => '.node_updated' do |t, args|
        cd "kernel" do
          ENV['NODE_PATH'] = "app:#{coffee_path}:spec:../assets/lib"
          sh "../node_modules/jasmine-node/bin/jasmine-node --coffee --test-dir spec"
        end
      end

      desc "Run cucumber.js features for kernel"
      task :features, [:file] => '.node_updated' do |t, args|
        prepare_for_features
        cd "kernel" do
          ENV['NODE_PATH'] = node_path_for_features
          features_to_be_run = args[:file] ? "#{kernel/features}/#{args[:file]}" : "features"
          sh "../node_modules/cucumber/bin/cucumber.js --tags @all,@kernel --tags ~@wip '#{features_to_be_run}'"
        end
      end

      namespace :features do
        task :wip => '.node_updated' do
          prepare_for_features
          cd "kernel" do
            ENV['NODE_PATH'] = node_path_for_features
            sh "../node_modules/cucumber/bin/cucumber.js --tags @wip --tags @kernel features"
          end
        end
      end

    end

  end

end
