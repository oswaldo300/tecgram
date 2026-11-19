# Animación Rive del oso (login)

El widget `OsoLogin` (`lib/widgets/oso_login.dart`) usa este archivo:

- `assets/rive/oso_login.riv`

Es el oso clásico de login de Rive (mira al campo activo, se tapa los ojos
al escribir algo secreto y celebra o se lamenta según el resultado).
Es el mismo oso del proyecto `login_osito_rive`, copiado de
`assets/login-bear.riv` de ese repo:

```bash
cp ../login_osito_rive/assets/login-bear.riv assets/rive/oso_login.riv
```

Si el archivo no está, la app usa el oso dibujado con widgets que ya
viene incluido en `oso_login.dart`.

Nota: la animación original del oso es de la comunidad de Rive, no es
código de Telegram ni de Cherrygram.
