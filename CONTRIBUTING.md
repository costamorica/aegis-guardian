# Contribution

## Principes

- garder les modules indépendants ;
- ne jamais masquer une erreur critique ;
- privilégier les commandes Linux standards ;
- documenter les comportements d’auto-réparation ;
- valider les scripts avec `bash -n` et ShellCheck.

## API minimale d’un module

```bash
module_name() {
    printf 'Nom du module'
}

module_check() {
    emit_result "module.id" "ok" false "Message" "Détails"
}
```

Statuts acceptés :

- `ok`
- `repaired`
- `warning`
- `critical`
