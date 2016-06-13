apt_update 'Update the apt cache daily' do
  frequency 86_400
  action :periodic
end

package 'curl'
package 'nginx'

user node['googl_api']['user']['username'] do
  comment node['googl_api']['user']['comment']
  group node['googl_api']['user']['group']
  home "/home/#{node['googl_api']['user']['username']}"
  supports manage_home: true
  system true
  shell node['googl_api']['user']['shell']
end

openssl_dhparam '/etc/ssl/certs/dhparam.pem' do
  key_length 2048
  generator 2
end
