# AltTabNeo

Switcher de ventanas para macOS, con vista previa de miniaturas y atajos personalizables.

**Autor:** [Facundo De Lima](https://github.com/facudelima)

## Características

- Cambio rápido entre ventanas (estilo Alt+Tab de Windows)
- Miniaturas, iconos de app y títulos configurables
- Sin telemetría, sin auto-updates remotos, sin licencias Pro
- Todas las funciones desbloqueadas

## Requisitos

- macOS 10.13 o posterior
- Permiso de **Accesibilidad** (obligatorio al primer arranque)

## Instalación

### Desde release (recomendado)

1. Descargá `AltTabNeo-1.0.1.dmg` o `AltTabNeo-1.0.1.zip` desde [Releases](https://github.com/facudelima/AltTabNeo/releases).
2. Arrastrá **AltTabNeo** a **Aplicaciones**.
3. Abrí la app y concedé Accesibilidad en Ajustes del Sistema.

### Desde código

```bash
git clone https://github.com/facudelima/AltTabNeo.git
cd AltTabNeo
open AltTabNeo.xcodeproj   # esquema Debug → ⌘R
```

Para instalar el build local en `/Applications`:

```bash
./scripts/build-release.sh
./scripts/install-to-applications.sh dist/AltTabNeo.app
```

## Compilar instalable

```bash
./scripts/build-release.sh      # Release → dist/AltTabNeo.app
./scripts/package-installer.sh  # dist/AltTabNeo-1.0.0.zip y .dmg
```

## Licencia

GPL-3.0 — ver [LICENCE.md](LICENCE.md).
