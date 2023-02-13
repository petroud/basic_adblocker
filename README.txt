-- Petrou Dimitrios ----


-- Tool Description -----------------------
This tool creates firewall rules for 
blocking domains specified in txt files 
using the iptables command. 
-------------------------------------------

-- General Specifications -----------------
>The tool is able to lookup on specified 
domains for an IP address. It only supports
IPv4 addresses. During construction of the 
IP list duplicate hosts are removed (some
domains point to same IPs).

>The tools blocks almost all of the ads on 
websites (90% of them, checked by visiting 
various websites and using this tool:

https://d3ward.github.io/toolz/adblock

Some ads are not
blocked because of lacking domains in the 
block list and others cannot be blocked 
because the ad server is the same with the
website server. For example the youtube
ads cannot be firewall blocked because
they are hosted on the same servers with 
the videos. So if someone tries to block
the IP of the server that serves the ad,
the main content will also be unavailable.
Those kind of ads can only be blocked client
side via browser scripts.

>This tool, upon specifications, DROPs packets
from specific IPs (that means the request
times out) and REJECTs packets from other 
IPs (that means the requestor gets
unreachable error).
-------------------------------------------
