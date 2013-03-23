name        'mod_cluster'
description 'mod_cluster server'

run_list *%w[
    mod_cluster::server
    apache2
]
