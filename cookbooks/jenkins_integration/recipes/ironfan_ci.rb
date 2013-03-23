#
# Cookbook Name:: jenkins_integration
# Recipe:: ironfan_ci
#
# Copyright 2012, Infochimps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ssh_dir                 = node[:jenkins][:server][:home_dir] + '/.ssh'
directory ssh_dir do
  owner         node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
  mode          '0700'
end

# Set up the correct public key
private_key_filename     = ssh_dir + '/id_rsa'
file private_key_filename do
  owner         node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
  content       node[:jenkins_integration][:ironfan_ci][:deploy_key]
  mode          '0600'
  notifies      :run, 'execute[Regenerate id_rsa.pub]', :immediately
end
execute 'Regenerate id_rsa.pub' do
  user          node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
  cwd           ssh_dir
  command       "ssh-keygen -y -f id_rsa -N'' -P'' > id_rsa.pub"
  action        :nothing
end

# Add Github's fingerprint to known_hosts
cookbook_file ssh_dir + '/github.fingerprint' do
  user          node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
  notifies      :run, 'execute[Get familiar with Github]', :immediately
end
execute 'Get familiar with Github' do
  user          node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
  cwd           ssh_dir
  command       "cat github.fingerprint >> known_hosts"
  action        :nothing
end

# FIXME: use https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
#   instead of developing this DSL->XML transformation further
node[:jenkins_integration][:pantries].each_pair do |name, attrs|
  # Initial trigger/tracking job. Have your pantry's post-commit 
  #   hook hit the API path for this job, to trigger the Ironfan CI
  #   (and stage the result if successful).
  attrs[:branch]  ||= node[:jenkins_integration][:ironfan_ci][:pantry_branch]
  attrs[:merge]   ||= node[:jenkins_integration][:ironfan_ci][:pantry_merge]
  jenkins_job name do
    project       attrs[:project]
    repository    attrs[:repository]
    branch        attrs[:branch]
    downstream    [ 'Ironfan CI' ]
    final         [ "stage_#{name}" ]
    final_params( { 'GIT_COMMIT' => { :type => 'git_commit' } })
    triggers(     { :poll_scm => true})
  end

  # Push the results of a successful CI run into the staging branch
  jenkins_job "stage_#{name}" do
    project       attrs[:project]
    repository    attrs[:repository]
    parameters(   { 'GIT_COMMIT' => {
                      :default  => "origin/#{attrs[:merge]}",   # Do nothing if called by default
                      :type     => 'string'
                  } })
    branch        '$GIT_COMMIT'
    merge         attrs[:merge]
  end
end

# Core integration job: this sets up the test universe homebase, syncs
#   to that universe's Chef Server, and launches the specified test
#   server, watching it run to completion
jenkins_job 'Ironfan CI' do
  repository    node[:jenkins_integration][:ironfan_ci][:repository]
  # Some short justification: why bash? Because these tools are 
  #   written for the command line. We can test internal interfaces
  #   via ruby, but external ones should use the command line.
  branch        node[:jenkins_integration][:ironfan_ci][:branch]
  templates     [ 'knife_shared.inc' ]
  tasks         [ 'bundler.sh', 'sync_changes.sh', 'launch.sh' ]
end

# Setup jenkins user to make commits
template node[:jenkins][:server][:home_dir] + '/.gitconfig' do
  source        '.gitconfig.erb'
  owner         node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
end

# FIXME: fucking omnibus
file node[:jenkins][:server][:home_dir] + '/.profile' do
  content       'export PATH=/opt/chef/embedded/bin/:$PATH'
  owner         node[:jenkins][:server][:user]
  group         node[:jenkins][:server][:group]
end
