[${groupname}]
%{ for s in servers}${s.name} ansible_host=${length(s.network) == 0 ? "" : s.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in s.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}
