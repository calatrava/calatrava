module Calatrava

  class Kernel
    include Rake::DSL

    def initialize(root)
      @path = root
    end

    def build_dir
      "build/kernel/js"
    end

    def modules
      Dir[File.join(@path, 'kernel/app/*')].select { |n| File.directory? n }.collect { |n| File.basename n }
    end

    def plugins
      Dir[File.join(@path, 'kernel/plugins/*')].select { |n| File.file? n }.collect { |n| File.basename n }
    end

    def coffee_path
      (['plugins'] + modules.collect { |m| "app/#{m}" }).join(':')
    end

    def prepare_for_features
      sh "ln -sFfh kernel/features/step_definitions/ features/step_definitions"
      sh "ln -sFfh kernel/features/support/ features/support"
    end

    def install_tasks
      directory build_dir

      desc "Build kernel js files"
      task :coffee => build_dir do
        coffee "kernel/app", build_dir
        coffee "kernel/plugins", build_dir
      end

      desc "Clean built kernel"
      task :clean do
        rm_rf build_dir
      end

      file '.node_updated' => 'package.json' do
        sh "npm install"
        sh "touch .node_updated"
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
          ENV['NODE_PATH'] = "#{coffee_path}:features/support:../assets/lib:features/step_definitions:../features/testdata"
          features_to_be_run = args[:file] ? "#{kernel/features}/#{args[:file]}" : "features"
          sh "../node_modules/cucumber/bin/cucumber.js --tags @all,@kernel --tags ~@wip '#{features_to_be_run}'"
        end
      end

      namespace :features do
        task :wip => '.node_updated' do
          prepare_for_features
          cd "kernel" do
            ENV['NODE_PATH'] = "#{coffee_path}:features/support:../assets/lib:features/step_definitions:../features/testdata"
            sh "../node_modules/cucumber/bin/cucumber.js --tags @wip --tags @kernel features"
          end
        end
      end

    end

  end

end
