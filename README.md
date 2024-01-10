# pgweb

## Abstract

To make PostgreSQL administration more accessible and to make the overall usage easier this provides [pgwb](http://sosedoff.github.io/pgweb/) which is a web-based database browser for PostgreSQL, written in Go with zero-dependency binaries. **pgweb** was created as an attempt to build very simple and portable application to work with local or remote PostgreSQL databases.


postgresql.data.svc.cluster.local

curl -i 'http://pgweb.data.svc.cluster.local:8080/static/js/jquery.js' \
-X 'GET' \
-H 'Accept: */*' \
-H 'Referer: http://pgweb.data.svc.cluster.local:8080/' \
-H 'Sec-Fetch-Dest: script' \
-H 'Sec-Fetch-Mode: no-cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15'