# rsyslog
Be sure to check on the SIEM's documentation before setting up rsyslog:
- [Devo](https://docs.devo.com/space/latest/94658299/rsyslog)
- [Trellix Helix](https://docs.trellix.com/bundle/helixconnect_dscg/page/UUID-5a8cd880-88d9-1fff-96e8-2329922ffd53.html)
- [Azure Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/forward-syslog-monitor-agent)

General Idea:
1. `sudo apt install rsyslog`
2. On `/etc/rsyslog.conf`, add `*.*@192.168.1.2:514` to the bottom of the file
3. `sudo service rsyslog restart`

## Auditd to rsyslog
1. `sudo apt-get install audispd-plugins`
2. On `/etc/audit/plugins.d/syslog.conf`, set `active = yes` and `args = LOG_LOCAL6`