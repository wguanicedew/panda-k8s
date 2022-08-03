# ngx_http_ssl_extension_module

allow proxy certificate in ingress-nginx, openssl X509_V_FLAG_ALLOW_PROXY_CERTS is not set

To fix::

2022/07/29 09:06:35 [info] 33#33: *241 client SSL certificate verify error: (40:proxy certificates
not allowed, please set the appropriate flag) while reading client request headers, client...

