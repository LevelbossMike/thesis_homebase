default[:jenkins_integration][:git][:name]      = 'Jenkins Integration'
default[:jenkins_integration][:git][:email]     = 'jenkins@example.org'

default[:jenkins_integration][:ironfan_ci][:repository]         = 'git@github.com:infochimps-labs/ironfan-homebase.git'
default[:jenkins_integration][:ironfan_ci][:chef_user]          = 'test'
default[:jenkins_integration][:ironfan_ci][:cluster]            = 'testharness'
default[:jenkins_integration][:ironfan_ci][:facet]              = 'simple'
default[:jenkins_integration][:ironfan_ci][:branch]             = 'master'

default[:jenkins_integration][:ironfan_ci][:pantry_branch]      = 'testing'
default[:jenkins_integration][:ironfan_ci][:pantry_merge]       = 'staging'

ironfan_pantry = Mash.new
ironfan_pantry[:project]        = 'https://github.com/infochimps-labs/ironfan-pantry/'
ironfan_pantry[:repository]     = 'git@github.com:infochimps-labs/ironfan-pantry.git'
default[:jenkins_integration][:pantries]['ironfan-pantry'] = ironfan_pantry

# Plugins that we need for the Ironfan CI job to work correctly
node.default[:jenkins][:server][:plugins] += %w[ join parameterized-trigger ]
