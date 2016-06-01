#
# Cookbook Name:: googl_api_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# setup
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

node.from_file run_context.resolve_attribute('nginx', 'source')
include_recipe 'nginx::default'
