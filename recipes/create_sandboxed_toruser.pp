Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

user { 'tor-user':
  ensure => present,
  uid => 23000
}

file { "/home/tor-user":
  ensure => "directory",
  owner  => "tor-user",
  require => User['tor-user'],
}

package { 'tor':
  ensure => 'latest'
}

file {'/etc/tor/torrc':
  require => Package['tor'],
  owner => 'root',
  backup => '.backup',
  content => '
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 53
RunAsDaemon 1
# For vidalia
ControlPort 9051
HashedControlPassword 16:F2D9E9F046471BE960D3B6B83CB360CC9B238F02BEFF34FE5ADE292E98 # The password is "torcontrol"'
}

exec { "remove_tor_from_autostart":
  require => Package['tor'],
  command => "sudo update-rc.d -f tor remove",
}

file {'/etc/tor/iptables_rules':
  require => Package['tor'],
  owner => 'root',
  content => '#
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A OUTPUT -p tcp -m owner --uid-owner 23000 -m tcp --dport 9040 -j ACCEPT
-A OUTPUT -p udp -m owner --uid-owner 23000 -m udp --dport 53 -j ACCEPT
-A OUTPUT -m owner --uid-owner 23000 -j DROP
COMMIT
*nat
#
:PREROUTING ACCEPT
:INPUT ACCEPT
:OUTPUT ACCEPT
:POSTROUTING ACCEPT
-A OUTPUT -d 192.168.0.0/16 -j RETURN
-A OUTPUT -d 127.0.0.0/16 -j RETURN
-A OUTPUT -p tcp -m owner --uid-owner 23000 -m tcp -j REDIRECT --to-ports 9040
-A OUTPUT -p udp -m owner --uid-owner 23000 -m udp --dport 53 -j REDIRECT --to-ports 53
COMMIT
'
}

exec { "configure_iptables_to_redirect_to_tor":
  command => 'iptables-restore < /etc/tor/iptables_rules',
  require => [File['/etc/tor/iptables_rules'], User['tor-user']],
}

file {'/home/tor-user/check_if_sandboxed_by_tor.py':
  require => User['tor-user'],
  owner => 'tor-user',
  content =>'#/usr/bin/env python
import sys
import requests
c = requests.get("https://check.torproject.org/").content
if "Sorry. You are not using Tor" in c:
    print "Tor not detected"
    sys.exit(1)
elif "Congratulations" in c:
    print "Tor detected!"
else:
    print "Tor not detected"
    sys.exit(1)
'
}
