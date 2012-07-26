require 'xcodeproj'

module Xcodeproj
  class Project
  	module Object

  	  class PBXResourcesBuildPhase < PBXBuildPhase
  	    has_many :files

  	    def initialize(*)
  	      super
  	      self.file_references ||= []
  	    end
  	    
  	  end

  	end
  end
end