use Test::Nginx::Socket 'no_plan';

run_tests();

__DATA__

=== TEST 1: rfc proxy certificate, no AC
--- main_config
    env X509_VOMS_DIR=t/vomsdir;
    env X509_CERT_DIR=t/trust-anchors;
--- http_config
    server {
        error_log logs/error.log debug;
        listen 8443 ssl;
        ssl_certificate ../../certs/nginx_voms_example.cert.pem;
        ssl_certificate_key ../../certs/nginx_voms_example.key.pem;
        ssl_client_certificate ../../trust-anchors/igi-test-ca.pem;
        ssl_verify_depth 10;
        ssl_verify_client on;
	location = / {
            default_type text/plain;
            echo $ssl_client_ee_cert;
        }
    }
--- config
    location = / {
        error_log logs/error-proxy.log debug;
        proxy_pass https://localhost:8443/;
        proxy_ssl_certificate ../../certs/0.cert.pem;
        proxy_ssl_certificate_key ../../certs/0.key.pem;
    }
--- request
GET / 
--- response_body
-----BEGIN CERTIFICATE-----
	MIIDnjCCAoagAwIBAgIBCTANBgkqhkiG9w0BAQUFADAtMQswCQYDVQQGEwJJVDEM
	MAoGA1UECgwDSUdJMRAwDgYDVQQDDAdUZXN0IENBMB4XDTEyMDkyNjE1MzkzNFoX
	DTIyMDkyNDE1MzkzNFowKzELMAkGA1UEBhMCSVQxDDAKBgNVBAoTA0lHSTEOMAwG
	A1UEAxMFdGVzdDAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDKxtrw
	hoZ27SxxISjlRqWmBWB6U+N/xW2kS1uUfrQRav6auVtmtEW45J44VTi3WW6Y113R
	BwmS6oW+3lzyBBZVPqnhV9/VkTxLp83gGVVvHATgGgkjeTxIsOE+TkPKAoZJ/QFc
	CfPh3WdZ3ANI14WYkAM9VXsSbh2okCsWGa4o6pzt3Pt1zKkyO4PW0cBkletDImJK
	2vufuDVNm7Iz/y3/8pY8p3MoiwbF/PdSba7XQAxBWUJMoaleh8xy8HSROn7tF2al
	xoDLH4QWhp6UDn2rvOWseBqUMPXFjsUi1/rkw1oHAjMroTk5lL15GI0LGd5dTVop
	kKXFbTTYxSkPz1MLAgMBAAGjgcowgccwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU
	fLdB5+jO9LyWN2/VCNYgMa0jvHEwDgYDVR0PAQH/BAQDAgXgMD4GA1UdJQQ3MDUG
	CCsGAQUFBwMBBggrBgEFBQcDAgYKKwYBBAGCNwoDAwYJYIZIAYb4QgQBBggrBgEF
	BQcDBDAfBgNVHSMEGDAWgBSRdzZ7LrRp8yfqt/YIi0ojohFJxjAnBgNVHREEIDAe
	gRxhbmRyZWEuY2VjY2FudGlAY25hZi5pbmZuLml0MA0GCSqGSIb3DQEBBQUAA4IB
	AQANYtWXetheSeVpCfnId9TkKyKTAp8RahNZl4XFrWWn2S9We7ACK/G7u1DebJYx
	d8POo8ClscoXyTO2BzHHZLxauEKIzUv7g2GehI+SckfZdjFyRXjD0+wMGwzX7MDu
	SL3CG2aWsYpkBnj6BMlr0P3kZEMqV5t2+2Tj0+aXppBPVwzJwRhnrSJiO5WIZAZf
	49YhMn61sQIrepvhrKEUR4XVorH2Bj8ek1/iLlgcmFMBOds+PrehSRR8Gn0IjlEg
	C68EY6KPE+FKySuS7Ur7lTAjNdddfdAgKV6hJyST6/dx8ymIkb8nxCPnxCcT2I2N
	vDxcPMc/wmnMa+smNal0sJ6m
	-----END CERTIFICATE-----
--- error_code: 200


=== TEST 2: EEC

--- main_config
    env X509_VOMS_DIR=t/vomsdir;
    env X509_CERT_DIR=t/trust-anchors;
--- http_config
    server {
        error_log logs/error.log debug;
        listen 8443 ssl;
        ssl_certificate ../../certs/nginx_voms_example.cert.pem;
        ssl_certificate_key ../../certs/nginx_voms_example.key.pem;
        ssl_client_certificate ../../trust-anchors/igi-test-ca.pem;
        ssl_verify_depth 10;
        ssl_verify_client on;
	location = / {
            default_type text/plain;
            echo $ssl_client_ee_cert;
        }
    }
--- config
    location = / {
        error_log logs/error-proxy.log debug;
        proxy_pass https://localhost:8443/;
        proxy_ssl_certificate ../../certs/test0.cert.pem;
        proxy_ssl_certificate_key ../../certs/9.key.pem;
    }
--- request
GET / 
--- response_body
-----BEGIN CERTIFICATE-----
	MIIDnjCCAoagAwIBAgIBCTANBgkqhkiG9w0BAQUFADAtMQswCQYDVQQGEwJJVDEM
	MAoGA1UECgwDSUdJMRAwDgYDVQQDDAdUZXN0IENBMB4XDTEyMDkyNjE1MzkzNFoX
	DTIyMDkyNDE1MzkzNFowKzELMAkGA1UEBhMCSVQxDDAKBgNVBAoTA0lHSTEOMAwG
	A1UEAxMFdGVzdDAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDKxtrw
	hoZ27SxxISjlRqWmBWB6U+N/xW2kS1uUfrQRav6auVtmtEW45J44VTi3WW6Y113R
	BwmS6oW+3lzyBBZVPqnhV9/VkTxLp83gGVVvHATgGgkjeTxIsOE+TkPKAoZJ/QFc
	CfPh3WdZ3ANI14WYkAM9VXsSbh2okCsWGa4o6pzt3Pt1zKkyO4PW0cBkletDImJK
	2vufuDVNm7Iz/y3/8pY8p3MoiwbF/PdSba7XQAxBWUJMoaleh8xy8HSROn7tF2al
	xoDLH4QWhp6UDn2rvOWseBqUMPXFjsUi1/rkw1oHAjMroTk5lL15GI0LGd5dTVop
	kKXFbTTYxSkPz1MLAgMBAAGjgcowgccwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU
	fLdB5+jO9LyWN2/VCNYgMa0jvHEwDgYDVR0PAQH/BAQDAgXgMD4GA1UdJQQ3MDUG
	CCsGAQUFBwMBBggrBgEFBQcDAgYKKwYBBAGCNwoDAwYJYIZIAYb4QgQBBggrBgEF
	BQcDBDAfBgNVHSMEGDAWgBSRdzZ7LrRp8yfqt/YIi0ojohFJxjAnBgNVHREEIDAe
	gRxhbmRyZWEuY2VjY2FudGlAY25hZi5pbmZuLml0MA0GCSqGSIb3DQEBBQUAA4IB
	AQANYtWXetheSeVpCfnId9TkKyKTAp8RahNZl4XFrWWn2S9We7ACK/G7u1DebJYx
	d8POo8ClscoXyTO2BzHHZLxauEKIzUv7g2GehI+SckfZdjFyRXjD0+wMGwzX7MDu
	SL3CG2aWsYpkBnj6BMlr0P3kZEMqV5t2+2Tj0+aXppBPVwzJwRhnrSJiO5WIZAZf
	49YhMn61sQIrepvhrKEUR4XVorH2Bj8ek1/iLlgcmFMBOds+PrehSRR8Gn0IjlEg
	C68EY6KPE+FKySuS7Ur7lTAjNdddfdAgKV6hJyST6/dx8ymIkb8nxCPnxCcT2I2N
	vDxcPMc/wmnMa+smNal0sJ6m
	-----END CERTIFICATE-----
--- error_code: 200
