namespace :kernel do

  directory "build/kernel/js" => "build"

  desc "Build kernel js files"
  task :kernel => "build/kernel/js" do
    coffee "kernel/app", "build/kernel/js"
  end

  desc "Clean built kernel"
  task :clean do
    rm_rf "build/kernel"
  end

  desc "Run jasmine test. If specs not given in argument, runs all test"
  task :spec => 'kernel/.node_updated' do |t, args|
    cd "kernel" do
      ENV['NODE_PATH'] = "app:#{Calatrava.src_paths}:spec:../assets/lib"
      sh "node_modules/jasmine-node/bin/jasmine-node --coffee --test-dir kernel/spec"
    end
  end

  file 'kernel/.node_updated' => 'kernel/package.json' do
    cd "kernel" do
      sh "npm install"
      sh "touch .node_updated"
    end
  end

  desc "Run cucumber.js features for kernel"
  task :features, [:file] => ['kernel/.node_updated', :create_sim_link] do |t, args|
    cd "kernel" do
      ENV['NODE_PATH'] = "#{CalatravaKernel.src_paths}:features/support:../assets/lib:features/step_definitions:../features/testdata"
      features_to_be_run = args[:file] ? "#{kernel/features}/#{args[:file]}" : "features"
      sh "node_modules/cucumber/bin/cucumber.js --tags @all,@kernel --tags ~@wip '#{features_to_be_run}'"
    end
  end

  namespace :features do
    task :wip => ['kernel/.node_updated', :create_sim_link] do
      cd "kernel" do
        ENV['NODE_PATH'] = "#{CalatravaKernel.src_paths}:features/support:../assets/lib:features/step_definitions:../features/testdata"
        sh "node_modules/cucumber/bin/cucumber.js --tags @wip --tags @kernel features"
      end
    end
  end

  desc "create sim link for the kernels step_definitions and support folder"
  task :create_sim_link do
    sh "ln -sFfh kernel/features/step_definitions/ features/step_definitions"
    sh "ln -sFfh kernel/features/support/ features/support"
  end

end
