```
{
  "ignition": {
    "config": {
      "append": [
        {
          "source": "<bootstrap_ignition_config_url>", 
          "verification": {}
        }
      ]
    },
    "timeouts": {},
    "version": "2.1.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {
    "files": [      
    {
       "filesystem": "root",
       "path": "/etc/sysctl.d/pmtu.conf",
       "user": {
         "name": "root"
       },
       "append": true,
       "contents": {
         "source": "data:text/plain;charset=utf-8;base64,bmV0LmlwdjQuaXBfbm9fcG10dV9kaXNjPTEKbmV0LmlwdjQucm91dGUubWluX3BtdHU9MTQ1MAo=",
         "verification": {}
       },
       "mode": 420
     },
    ]
  },
  "systemd": {}
}
```

net.ipv4.ip_no_pmtu_disc=1

net.ipv4.route.min_pmtu=1450