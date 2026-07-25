module_name() {
    printf 'Services'
}

module_check() {
    check_service "service.docker" "docker"
    check_service "service.caddy" "caddy"
    check_service "service.mariadb" "mariadb"
    check_service "service.php" "php8.4-fpm"
    check_service "service.fail2ban" "fail2ban"
}
