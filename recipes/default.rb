#
# Cookbook Name:: googl_api_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_update 'Update the apt cache daily' do
  frequency 86_400
  action :periodic
end

package 'curl'

user node['googl_api']['user']['username'] do
  comment node['googl_api']['user']['comment']
  group node['googl_api']['user']['group']
  home "/home/#{node['googl_api']['user']['username']}"
  supports manage_home: true
  system true
  shell node['googl_api']['user']['shell']
end

application_hash = search(:aws_opsworks_app, "shortname:googl_api").first.to_hash

magic_shell_environment 'PATH' do
  value '/opt/ruby_build/builds/2.3/bin:$PATH'
end

magic_shell_environment 'GOOGL_API_KEY' do
  value application_hash['environment']['GOOGL_API_KEY']
end

application '/srv/googl_api' do
  environment GOOGL_API_KEY: application_hash['environment']['GOOGL_API_KEY']
  owner node['googl_api']['user']['username']
  group node['googl_api']['user']['group']
  git do
    user node['googl_api']['user']['username']
    group node['googl_api']['user']['group']
    repository application_hash['app_source']['url']
  end
  #change to 'myapp' and get ruby version from attrs?
  ruby_runtime '2.3' do
    provider :ruby_build
    version '2.3'
  end
  bundle_install do
    user node['googl_api']['user']['username']
    deployment true
    without %w{development test}
  end
  rails do
    secret_token 'its_a_secret'
    migrate false
  end
  unicorn do
    port 8000
  end
end