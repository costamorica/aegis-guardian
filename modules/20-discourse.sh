module_name() {
    printf 'Discourse'
}

module_check() {
    check_container "discourse.container" "$DISCOURSE_CONTAINER"
    check_http_local "discourse.http" "$FORUM_URL" "$FORUM_DOMAIN"
}
