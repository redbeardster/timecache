In order to start you should have rebar2 installed

$rebar get-deps compile
$cd rel
$rebar generate
$timecache/bin/timecache console


$curl "localhost:8181/add?key=abc&value=123&ttl=1000"
$curl "localhost:8181/get?key=abc"

