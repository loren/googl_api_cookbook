describe service 'nginx' do
  it { is_expected.to_not be_enabled }
  it { is_expected.to be_running }
end

describe service 'googl_api' do
  it { is_expected.to be_enabled }
  it { is_expected.to be_running }
end

describe command 'curl -k https://localhost/shorten' do
  its('stdout') { is_expected.to include('missing_parameters') }
end

describe port 443 do
  it { is_expected.to be_listening }
end

describe port 80 do
  it { is_expected.to_not be_listening }
end

describe file('/srv/googl_api/config/secrets.yml') do
  its('content') { is_expected.to include('secret_key_base: also_a_secret') }
end

describe command '/opt/ruby_build/builds/2.3/bin/ruby -v' do
  its('stdout') { is_expected.to include('ruby 2.3') }
end
