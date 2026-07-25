module_name() {
    printf 'Site web'
}

module_check() {
    check_http_local "website.http" "$SITE_URL" "$SITE_DOMAIN"
}
