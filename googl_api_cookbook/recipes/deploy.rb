if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  application_hash = search(:aws_opsworks_app, 'shortname:googl_api').first.to_hash
end

deploy_to = "#{node['deploy']['root_directory']}/#{application_hash['shortname']}"

application deploy_to do
  environment GOOGL_API_KEY: application_hash['environment']['GOOGL_API_KEY']
  owner node['googl_api']['user']['username']
  group node['googl_api']['user']['group']
  git do
    user node['googl_api']['user']['username']
    group node['googl_api']['user']['group']
    repository application_hash['app_source']['url']
  end
  ruby_runtime '2.3' do
    provider :ruby_build
    version '2.3'
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
  ruby_bin = '/opt/ruby_build/builds/2.3/bin'
  poise_service_options deploy_to do
    command "#{ruby_bin}/ruby #{ruby_bin}/bundle exec #{ruby_bin}/ruby #{deploy_to}/vendor/bundle/ruby/2.3.0/bin/unicorn -c config/unicorn.rb #{deploy_to}/config.ru"
  end
end

template "#{node['nginx']['dir']}/sites-available/default" do
  cookbook 'googl_api_cookbook'
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
