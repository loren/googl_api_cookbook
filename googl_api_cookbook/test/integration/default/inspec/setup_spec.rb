describe os[:family] do
  it { should eq 'ubuntu' }
end

describe package 'curl' do
  it { is_expected.to be_installed }
end

describe user('deploy') do
  it { should exist }
  its('group') { should eq 'www-data' }
  its('home') { should eq '/home/deploy' }
  its('shell') { should eq '/bin/bash' }
end

describe file('/etc/ssl/certs/dhparam.pem') do
  its('content') { is_expected.to include('BEGIN DH PARAMETERS') }
end
