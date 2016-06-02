require 'rubygems'
require 'bundler'
require 'rake'
require 'git'
require 'fileutils'

build_dir = 'build'
source_dir = "#{build_dir}/source"
target_dir = "#{build_dir}/target"
vendor_dir_name = 'vendor'
vendor_dir = "#{build_dir}/#{vendor_dir_name}"

remote_origin_url = Git.open('.').config['remote.origin.url']
puts "remote_origin_url: #{remote_origin_url}"
source_log = nil

desc 'build cookbooks from remote branches'
task :build_remote, [:source_branch, :target_branch] => [:pull_source_branch, :update_target_branch, :clean]

desc 'pull source branch'
task :pull_source_branch, :source_branch do |_t, args|
  args.with_defaults(source_branch: 'source')
  source_branch = args[:source_branch]

  g = Git.clone remote_origin_url, 'source', branch: source_branch, path: build_dir
  source_log = g.log.first
  cd source_dir do
    sh "bundle exec berks vendor ../#{vendor_dir_name}"
  end
end

desc 'update target branch'
task :update_target_branch, :target_branch do |_t, args|
  args.with_defaults(target_branch: 'master')
  target_branch = args[:target_branch]
  puts "building: #{target_branch}"

  remotes = Git.ls_remote remote_origin_url
  initial_commit = remotes['branches'][target_branch].nil?

  if initial_commit
    g = Git.init target_dir
    g.config 'remote.origin.url', remote_origin_url
    g.checkout target_branch, new_branch: true
  else
    clone_options = { branch: target_branch, path: build_dir }
    g = Git.clone remote_origin_url, 'target', clone_options
    rm_r Dir.glob("#{target_dir}/*")
  end

  puts 'copying from vendor directory'
  cp_r "#{vendor_dir}/.", target_dir

  g.add(all: true)

  if initial_commit || !g.diff.name_status.empty?
    g.commit_all("#{source_log.message} [#{source_log.sha.slice(0, 10)}]")
    g.push 'origin', target_branch
    puts "pushed #{g.log.first.sha} to #{target_branch}"
  else
    puts "no changes to #{target_branch}"
  end
end

task :clean do
  rm_r build_dir
  g = Git.init
  g.fetch 'origin'
end
