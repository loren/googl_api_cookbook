if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  application_hash = search(:aws_opsworks_app, 'shortname:googl_api').first.to_hash
end

deploy_to = "#{node['deploy']['root_directory']}/#{application_hash['shortname']}"

service 'nginx' do
  supports status: true, restart: true, reload: true
end

magic_shell_environment 'GOOGL_API_KEY' do
  value application_hash['environment']['GOOGL_API_KEY']
end

cookbook_file '/etc/nginx/nginx.conf' do
  mode '0600'
  owner 'root'
  group 'root'
  source 'nginx.conf'
  notifies :restart, 'service[nginx]'
end

directory '/etc/nginx/ssl' do
  action :create
  owner 'root'
  group 'root'
  mode '0600'
end

template "/etc/nginx/ssl/#{application_hash['domains'].first}.crt" do
  mode '0600'
  source 'ssl.key.erb'
  variables key: application_hash['ssl_configuration']['certificate']
  notifies :restart, 'service[nginx]'
  only_if { application_hash['enable_ssl'] }
end

template "/etc/nginx/ssl/#{application_hash['domains'].first}.key" do
  mode '0600'
  source 'ssl.key.erb'
  variables key: application_hash['ssl_configuration']['private_key']
  notifies :restart, 'service[nginx]'
  only_if { application_hash['enable_ssl'] }
end

template "/etc/nginx/ssl/#{application_hash['domains'].first}.ca" do
  mode '0600'
  source 'ssl.key.erb'
  variables key: application_hash['ssl_configuration']['chain']
  notifies :restart, 'service[nginx]'
  only_if { application_hash['enable_ssl'] && application_hash['ssl_configuration']['chain'] }
end

template "/etc/logrotate.d/#{application_hash['shortname']}" do
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

application deploy_to do
  environment GOOGL_API_KEY: application_hash['environment']['GOOGL_API_KEY']
  owner node['googl_api']['user']['username']
  group node['googl_api']['user']['group']
  git do
    user node['googl_api']['user']['username']
    group node['googl_api']['user']['group']
    repository application_hash['app_source']['url']
  end
  ruby_version = application_hash['environment']['RUBY_VERSION']
  ruby_bin = "/opt/ruby_build/builds/#{ruby_version}/bin"
  ruby_runtime ruby_version do
    provider :ruby_build
    version ruby_version
  end
  bundle_install do
    user node['googl_api']['user']['username']
    deployment true
    without %w(development test)
  end
  rails do
    secret_token application_hash['environment']['GOOGL_API_KEY']
  end
  unicorn
  # Set config file in unicorn block when https://github.com/poise/application_ruby/pull/83 is merged
  poise_service_options deploy_to do
    command "#{ruby_bin}/ruby #{ruby_bin}/bundle exec #{ruby_bin}/ruby #{deploy_to}/vendor/bundle/ruby/2.3.0/bin/unicorn -c config/unicorn.rb #{deploy_to}/config.ru"
  end

  magic_shell_environment 'PATH' do
    value "#{ruby_bin}:$PATH"
  end
end

template '/etc/nginx/sites-available/default' do
  source 'default.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :reload, 'service[nginx]'
  variables(
    application: application_hash,
    deploy_to: deploy_to
  )
end
