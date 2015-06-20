#Pan Status

Web status pages to show IPV4 ping state of nodes in the cluster and the IBLinkinfo state

Pages use Ajax calls to retrieve json state files from the web server, and then change the HTML table cell background colour to match the state.  

All web pages are essentially identical, excepting the json state file they retrieve. Only this first part of the HTML file is different.

```
<html>
  <head>
  <title>TDC</title>
  <meta name="robots" content="noindex,nofollow" />
  <meta name="description" content="Pan Cluster Management IPV4 Ping State" />
  
  <script> var ping_target='management_net';
           var state_file='rack_management_state.json'
           var page_header='Management IPV4 Ping State'
  </script>
```

##fping script
bin/collect_ipv4_state.sh is called to fping each host in the conf/host_* files. These files are generated from the www/rack_master.json file, which defines which host is in which rack, and what the hostnames are on each network the host has an interface.

##rack_master.json

eg.

```
{
  "rack": {
    "B15": {
      "IBM_ID": "A3",
      "U": 42,
      "nodes": {
        "U1": {"model": "X3650_M3", "u": 1, "u_depth": 2, "management_net": "gpfs-a3-001-m", "provisioning_net": "gpfs-a3-001-p", "ipoib_net": "", "ib_net": "gpfs-a3-001-ib" },
        ...
      }
    }
  }
}
```

A BLANK model is a special case to say this U in the rack is empty (a table cell with Black background and a white border).
Not specifying a U will result in that U being assigned a BLANK model.
If the HTML table has more U than are specified, the remaining U have a Black background and black border.

e.g.
```
"U7": { "model": "BLANK", "u": 7, "u_depth": 1, "management_net": "", "provisioning_net": "", "ipoib_net": "", "ib_net": ""},
```

