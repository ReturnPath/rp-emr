require 'bundler/gem_tasks'
require 'gemfury'
require 'gemfury/command'
require 'rspec/core/rake_task'
require 'rubygems/package'

require 'dp-emr'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# This hacks Bundler's `rake release` task to push to Gem Fury instead.
module Bundler
  class GemHelper
    def release_gem(build_gem_path=nil)
      guard_clean
      built_gem_path ||= build_gem
      tag_version { git_push } unless already_tagged?
      gemfury_push(built_gem_path) if gem_push?
    end

    protected

    def gemfury_push(path)
      if Pathname.new("~/.gem/credentials").expand_path.exist?
        sh("fury push '#{path}'")
        Bundler.ui.confirm "Pushed #{name} #{version} to gemfury.com."
      else
        raise "Your Gem Fury credentials aren't set. Run `fury push` to set them."
      end
    end
  end
end
