$::facts['partitions']
$::facts['partitions'] =~ Struct
$::facts['partitions'] =~ Hash

$::facts['partitions'].each |String $index, Hash $value| {
  $output = "${index} = ${value}"
}
