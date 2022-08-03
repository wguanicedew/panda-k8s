/*
 * Copyright (C) Wen Guan
 * Copyright (C) wguan.icedew@gmail.com.
 */

#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>


typedef struct {
    ngx_uint_t  ssl_allow_proxy;
} ngx_http_ssl_extension_srv_conf_t;


static void *
ngx_http_ssl_extension_create_srv_conf(ngx_conf_t *cf)
{
    ngx_http_ssl_extension_srv_conf_t  *sscf;

    sscf = ngx_pcalloc(cf->pool, sizeof(ngx_http_ssl_extension_srv_conf_t));
    if (sscf == NULL) {
        return NULL;
    }

    sscf->ssl_allow_proxy = NGX_CONF_UNSET;
    return sscf;
}


static char *
ngx_http_ssl_extension_merge_srv_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_ssl_extension_srv_conf_t *prev = parent;
    ngx_http_ssl_extension_srv_conf_t *conf = child;

    ngx_conf_merge_uint_value(conf->ssl_allow_proxy, prev->ssl_allow_proxy, 0);

    return NGX_OK;
}


static char *
ngx_http_ssl_extension_allow_proxy(ngx_conf_t *cf, void *post, void *data)
{
    ngx_http_ssl_srv_conf_t  *sscf;

    ngx_flag_t  *fp = data;
    if (*fp == 0) {
        return NGX_CONF_OK;
    }

    sscf = ngx_http_conf_get_module_srv_conf(cf, ngx_http_ssl_module);

    if (sscf->ssl.ctx != NULL) {
        X509_STORE* store = SSL_CTX_get_cert_store(sscf->ssl.ctx);
        if (store == NULL) {
            ngx_log_error(NGX_LOG_ALERT, cf->log, 0, "SSL_CTX_get_cert_store() failed");
            return NGX_CONF_ERROR;
        }
        X509_STORE_CTX_set_flags(sscf->ssl.ctx, X509_V_FLAG_ALLOW_PROXY_CERTS);
	ngx_log_error(NGX_LOG_NOTICE, cf->log, 0, "Foo Module is enabled");
    }

    return NGX_CONF_OK;
}


static ngx_conf_post_t  ngx_http_ssl_extension_allow_proxy_post = { ngx_http_ssl_extension_allow_proxy };


static ngx_command_t  ngx_http_ssl_extension_commands[] = {

    { ngx_string("ssl_allow_proxy"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      0,
      offsetof(ngx_http_ssl_extension_srv_conf_t, ssl_allow_proxy),
      &ngx_http_ssl_extension_allow_proxy_post },

      ngx_null_command
};


static ngx_http_module_t  ngx_http_ssl_extension_module_ctx = {
    NULL,                                            /* preconfiguration */
    NULL,                                            /* postconfiguration */

    NULL,                                  /* create main configuration */
    NULL,                                  /* init main configuration */

    ngx_http_ssl_extension_create_srv_conf,          /* create server configuration */
    ngx_http_ssl_extension_merge_srv_conf,           /* merge server configuration */

    NULL,                                  /* create location configuration */
    NULL                                   /* merge location configuration */
};


ngx_module_t  ngx_http_ssl_extension_module = {
    NGX_MODULE_V1,
    &ngx_http_ssl_extension_module_ctx,              /* module context */
    ngx_http_ssl_extension_commands,                 /* module directives */
    NGX_HTTP_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};

