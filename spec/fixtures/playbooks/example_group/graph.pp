graph
file{'/tmp/test': ensure => present}
file{'/tmp/test2': ensure => present}
service{'httpd': ensure => running }
file{'/tmp/test3': ensure => present, notify => Service['httpd']}
file{'/tmp/test4': ensure => present, require => File['/tmp/test2']}