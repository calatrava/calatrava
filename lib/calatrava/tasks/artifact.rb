def artifact(path, env = nil)
  artifact_dir = env.nil? ? "artifacts/" : "artifacts/#{env}/"
  mkdir_p artifact_dir
  cp path, artifact_dir, :preserve => true
end

def artifact_dir(source_path, name)
  artifact_dir_path = "artifacts/#{name}/"
  mkdir_p artifact_dir_path
  sh "cp -R #{source_path}/* #{artifact_dir_path}"
end

def artifact_path(sub_path)
  File.join("artifacts", sub_path)
end

namespace :artifact do
  
  desc "Removes all pre-existing artifacts"
  task :clean do
    rm_rf "artifacts/*.*"
  end

end
