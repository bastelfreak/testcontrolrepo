# Demo controlrepo for PEADM

Goal of this controlrepo is to convert existing PE 2019.8.1 (or newer) setups to PEADM.
The installations are in restricted environments and no ssh access is possible.

To view the plans, go to: https://github.com/bastelfreak/testcontrolrepo/tree/peadm/site/profiles/plans

To view the cleanup puppet code, go to: https://github.com/bastelfreak/testcontrolrepo/blob/peadm/site/profiles/manifests/cleanup.pp

To see how we create the bolt project to start bolt via PE-Orchestrator, go to: https://github.com/bastelfreak/testcontrolrepo/blob/peadm/site/profiles/manifests/boltprojects.pp

To see my config management talk about it, check: https://cfp.cfgmgmtcamp.org/ghent2025/talk/9NUL9E/

a pe.conf for new installations:

```
{
  "puppet_enterprise::profile::master::r10k_remote": "https://github.com/bastelfreak/testcontrolrepo.git",
  "puppet_enterprise::profile::master::code_manager_auto_configure": true,
  "console_admin_password": "TimIsTesting2024!",
  "puppet_enterprise::puppet_master_host": "%{trusted.certname}"
}
```

To test this (works also with existing installations):

* Configure this repo as your control-repo
* create an environment nodegroup for `peadm`, assign your primary to it
* Assign the `profiles::cleanup` and `profiles::boltprojects` classes

* run your puppet agent

to convert and Upgrade, take a look at the plans in `site/profiles/plans`

starting the bolt service:

```
systemctl start peadmmig@profiles::convert.service
```

checking the status

```
systemctl status peadmmig@profiles::convert.service
```

watching the service

```
journalctl --unit peadmmig@profiles::convert.service --follow
```

Start a convert and upgrade to PE 2023.8.1

```
systemctl start peadmmig@profiles::convertandupgradeto2023.service
```
## License

GPL-3.0-only, see LICENSE file
