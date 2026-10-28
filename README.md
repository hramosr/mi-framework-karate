\# mi-framework-karate

Proyecto base del curso **Automatización de APIs con Karate DSL** (Karate **2.1.3**, Java 21).
Apunta a la **Novus Fintech Demo API** (cuentas y transferencias): <https://novus-fintech-demo-api.onrender.com/docs>

## Requisitos

| Herramienta | Versión | Verificar |
|---|---|---|
| Java (JDK) | 21 o superior | `java -version` |
| Maven | 3.9 o superior | `mvn -v` |
| Git y cuenta en GitHub | cualquiera reciente | `git --version` |
| VS Code + extensión Karate | `karatelabs.karate` | — |

## Credenciales

Te las da el instructor (`alumno01`, `alumno02`…). Se leen de **variables de entorno**; nunca las escribas en el código ni las subas a Git.

```bash
# Windows (PowerShell, para la sesión actual)
$env:NOVUS_USER = "alumno01"
$env:NOVUS_PASS = "tu-clave"

# Windows (permanente; cierra y abre la terminal después)
setx NOVUS_USER "alumno01"
setx NOVUS_PASS "tu-clave"

# macOS / Linux
export NOVUS_USER=alumno01
export NOVUS_PASS=tu-clave
```

## Ejecutar en tu equipo

```bash
mvn test                                         # todos los runners
mvn test -Dtest=HealthTest                       # un solo runner
mvn test -Dkarate.env=qa                         # ambiente qa (por defecto: dev)
mvn test -Dtest=ParallelTest                     # toda la suite en paralelo (CI)
mvn test -Dtest=ParallelTest -Dkarate.options="--tags @smoke"
mvn test -Dhost=http://localhost:3000            # otro servidor (opcional)
```

Reporte HTML: `target/karate-reports/karate-summary.html` (empieza aquí).

> La primera llamada puede tardar hasta un minuto: el servidor gratuito se duerme tras un rato sin uso. El timeout por defecto es de 60 s (`-Dtimeout=...` para cambiarlo).

En PowerShell, pon cada argumento completo entre comillas: `mvn test "-Dtest=ParallelTest" "-Dkarate.options=--tags @smoke"`.

## Estructura

```
mi-framework-karate/
├── pom.xml
├── .github/workflows/karate.yml   # sesión 3 (GitHub Actions)
└── src/test/java/
    ├── karate-config.js           # ambiente, URL base, timeouts y credenciales
    ├── logback-test.xml
    ├── features/
    │   ├── health/                # ya incluido: health.feature + HealthTest.java
    │   ├── accounts/              # tus features de cuentas (labs 1 y 2)
    │   └── transfers/             # tus features de transferencias (lab 3)
    ├── common/                    # auth.feature (login), reset.feature (POST /me/reset)
    ├── data/                      # account.json (cuerpo base para crear cuentas)
    ├── schemas/                   # account.json y contact.json (contratos)
    └── runners/
        └── ParallelTest.java      # ejecución paralela para CI
```

## Cómo avanzar por sesión

1. **Sesión 1:** ejecuta `HealthTest`. Crea `features/accounts/accounts.feature` con el login en el `Background` (`path 'auth', 'login'`, `configure headers`). Para correr un feature nuevo, copia `HealthTest.java` a su carpeta y cambia el nombre del feature.
2. **Sesión 2:** en `karate-config.js` descomenta el bloque de `callSingle` (login una sola vez) y quita el login de tus `Background`.
3. **Sesión 3:** ejecuta `ParallelTest`, etiqueta con `@smoke` / `@regression` y automatiza con GitHub Actions (Lab 4 y cierre del proyecto integrador): `.github/workflows/karate.yml`, secrets `NOVUS_USER` y `NOVUS_PASS`, variable `API_URL`.

## Subir el proyecto a GitHub

1. En github.com crea un repositorio **vacío** (sin README, sin `.gitignore` y sin licencia) y copia su URL.
2. En la carpeta del proyecto (la que tiene el `pom.xml`):

```bash
git init
git add .
git commit -m "Proyecto base Karate"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git push -u origin main
```

Antes del commit, revisa con `git status` que no aparezcan `target/`, `.DS_Store` ni archivos con contraseñas (el `.gitignore` ya excluye `target/` y `.env`). Si `git add .` falla con `does not have a commit checked out`, hay un repositorio anidado: borra su carpeta `.git`.

## CI con GitHub Actions

El workflow `.github/workflows/karate.yml` ejecuta `ParallelTest` en una máquina limpia de GitHub (Java 21 y caché de Maven) y publica el reporte como artefacto.

### Cuándo corre

| Disparador | Qué ejecuta |
|---|---|
| `push` a `main` | Smoke (`@smoke`) en `qa` |
| `pull_request` | Smoke (`@smoke`) en `qa` |
| Cada noche (06:00 UTC = 01:00 en Lima) | Regresión (`@regression`) en `qa` |
| A mano: **Actions → Karate API tests → Run workflow** | El ambiente (`dev` o `qa`) y las etiquetas que elijas |

Las etiquetas se ponen en los features (`@smoke`, `@regression`); si ningún escenario las tiene, no se ejecuta nada.

### Configuración (una sola vez)

1. En **Settings → Secrets and variables → Actions → Secrets** crea `NOVUS_USER` y `NOVUS_PASS`.
2. Opcional: en la pestaña **Variables** crea `API_URL` (por defecto usa la URL de la API del curso). Solo sirve para despertar el servidor antes de las pruebas; el host de las pruebas viene de `karate-config.js`.
3. Haz commit y push de `.github/` a la rama principal. El workflow aparece en la pestaña **Actions**.

### Leer una ejecución

1. **Actions** → elige la ejecución (verde = pasó, rojo = falló).
2. Abre el job y expande el paso que falló; los secrets aparecen como `***`.
3. Al final de la página **Summary**, en *Artifacts*, descarga `karate-report` y abre `karate-summary.html`. Se conserva 14 días.
4. **Re-run failed jobs** repite solo lo que falló.

### Buenas prácticas incluidas en el workflow

- Permisos mínimos (`permissions: contents: read`) y credenciales solo en Secrets, pasadas únicamente al paso de Karate.
- `timeout-minutes: 20` y `concurrency` (un pull request nuevo cancela la corrida anterior).
- `persist-credentials: false` en `checkout`: el token no queda guardado en el repositorio local.
- Reporte publicado con `if: always()`, para tenerlo aunque fallen los tests.
- Acciones en su versión mayor vigente: `actions/checkout@v7`, `actions/setup-java@v6` y `actions/upload-artifact@v7`.

Los pull requests desde forks no reciben los secrets: el login falla en ellos.

## Ayuda rápida

| Síntoma | Causa probable |
|---|---|
| `401 INVALID_CREDENTIALS` / `MISSING_CREDENTIALS` | `NOVUS_USER` o `NOVUS_PASS` no están definidas en la misma terminal que ejecuta Maven |
| `No tests found` | El `.feature` y su runner `.java` no están en la misma carpeta |
| Error de versión de Java | `JAVA_HOME` apunta a un JDK anterior a 21 |
| Timeout en la primera llamada | Arranque en frío del servidor: espera y reintenta |
| Datos raros en tus cuentas | `POST /me/reset` (o `common/reset.feature`) restaura tus datos iniciales |
| El workflow no aparece en Actions | El archivo debe estar en `.github/workflows/` (plural), en la raíz, y con push a la rama principal |
| En Actions falla con `Faltan NOVUS_USER y NOVUS_PASS` | Faltan los secrets o no se pasan al paso de Karate con `env:` |
| En Actions pasa pero no ejecuta escenarios | Las etiquetas del workflow no coinciden con las de tus features |
| El workflow falla al abrir el archivo | Error de sangría en el YAML: usa dos espacios, nunca tabuladores |
