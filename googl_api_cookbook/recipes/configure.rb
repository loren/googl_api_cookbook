if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  application_hash = search(:aws_opsworks_app, 'shortname:googl_api').first.to_hash
end

deploy_to = "#{node['deploy']['root_directory']}/#{application_hash['shortname']}"

magic_shell_environment 'PATH' do
  value '/opt/ruby_build/builds/2.3/bin:$PATH'
end

magic_shell_environment 'GOOGL_API_KEY' do
  value application_hash['environment']['GOOGL_API_KEY']
end

directory "#{node['nginx']['dir']}/ssl" do
  action :create
  owner 'root'
  group 'root'
  mode 0600
end

template "#{node['nginx']['dir']}/ssl/#{application_hash['domains'].first}.crt" do
  cookbook 'googl_api_cookbook'
  mode '0600'
  source 'ssl.key.erb'
  variables key: application_hash['ssl_configuration']['certificate']
  notifies :restart, 'service[nginx]'
  only_if { application_hash['enable_ssl'] }
end

template "#{node['nginx']['dir']}/ssl/#{application_hash['domains'].first}.key" do
  cookbook 'googl_api_cookbook'
  mode '0600'
  source 'ssl.key.erb'
  variables key: application_hash['ssl_configuration']['private_key']
  notifies :restart, 'service[nginx]'
  only_if { application_hash['enable_ssl'] }
end

template "#{node['nginx']['dir']}/ssl/#{application_hash['domains'].first}.ca" do
  cookbook 'googl_api_cookbook'
  mode '0600'
  source 'ssl.key.erb'
  variables key: application_hash['ssl_configuration']['chain']
  notifies :restart, 'service[nginx]'
  only_if { application_hash['enable_ssl'] && application_hash['ssl_configuration']['chain'] }
end

template "/etc/logrotate.d/#{application_hash['shortname']}" do
  cookbook 'googl_api_cookbook'
  source 'unicorn_logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    deploy_to: deploy_to,
    user: node['googl_api']['user']['username'],
    group: node['googl_api']['user']['group']
  )
end

template '/etc/logrotate.d/nginx' do
  cookbook 'googl_api_cookbook'
  source 'nginx_logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    log_dir: node['nginx']['log_dir'],
    pid: node['nginx']['pid'],
    username: node['nginx']['user']
  )
end
