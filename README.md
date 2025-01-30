# Demo controlrepo for PEADM

Goal of this controlrepo is to convert existing PE 2019.8.1 (or newer) setups
to PEADM. The installations are in restricted environments and no ssh access is
possible.

To view the plans, go to: https://github.com/bastelfreak/testcontrolrepo/tree/peadm/site/profiles/plans

To view the cleanup puppet code, go to: https://github.com/bastelfreak/testcontrolrepo/blob/peadm/site/profiles/manifests/cleanup.pp

To see how we create the bolt project to start bolt via PE-Orchestrator, go to: https://github.com/bastelfreak/testcontrolrepo/blob/peadm/site/profiles/manifests/boltprojects.pp

To see my config management talk about it, check: https://cfp.cfgmgmtcamp.org/ghent2025/talk/9NUL9E/

To test this:

* Configure this repo as your control-repo
* create an environment nodegroup for `peadm`, assign your primary to it
* Assign the `profiles::cleanup` and `profiles::boltprojects` classes

* run your puppet agent

to conert and Upgrade, take a look at the plans in `site/profiles/plans`

## License

GPL-3.0-only, see LICENSE file
