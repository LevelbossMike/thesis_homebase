# Ironfan Knife Commands

## Available Commands

Available cluster subcommands: (for details, `knife SUB-COMMAND --help`)

    knife cluster list (options)                                  - show available clusters
    knife cluster bootstrap   CLUSTER-[FACET-[INDEXES]] (options) - bootstrap all servers described by given cluster slice
    knife cluster kick        CLUSTER-[FACET-[INDEXES]] (options) - start a run of chef-client on each server, tailing the logs and exiting when the run completes.
    knife cluster kill        CLUSTER-[FACET-[INDEXES]] (options) - kill all servers described by given cluster slice
    knife cluster launch      CLUSTER-[FACET-[INDEXES]] (options) - Creates chef node and chef apiclient, pre-populates chef node, and instantiates in parallel their cloud machines. With --bootstrap flag, will ssh in to machines as they become ready and launch the bootstrap process
    knife cluster proxy       CLUSTER-[FACET-[INDEXES]] (options) - Runs the ssh command to open a SOCKS proxy to the given host, and writes a PAC (automatic proxy config) file to /tmp/ironfan_proxy-YOURNAME.pac. Only the first host is used, even if multiple match.
    knife cluster show        CLUSTER-[FACET-[INDEXES]] (options) - a helpful display of cluster's cloud and chef state
    knife cluster ssh         CLUSTER-[FACET-[INDEXES]] COMMAND (options) - run an interactive ssh session, or execuse the given command, across a cluster slice
    knife cluster start       CLUSTER-[FACET-[INDEXES]] (options) - start all servers described by given cluster slice
    knife cluster stop        CLUSTER-[FACET-[INDEXES]] (options) - stop all servers described by given cluster slice
    knife cluster sync        CLUSTER-[FACET-[INDEXES]] (options) - Update chef server and cloud machines with current cluster definition
    knife cluster vagrant CMD CLUSTER-[FACET-[INDEXES]] (options) - runs the given command against a vagrant environment created from your cluster definition. EARLY, use at your own risk

## Examples

