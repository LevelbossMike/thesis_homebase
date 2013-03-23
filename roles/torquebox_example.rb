name        'torquebox_example'
description 'TorqueBox Server EC2 example App'

run_list *%w[
    torquebox::server
    torquebox::backstage
    torquebox::example
]
