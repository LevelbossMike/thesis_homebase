name        'torquebox'
description 'TorqueBox Server'

run_list *%w[
    torquebox::server
    torquebox::backstage
]
