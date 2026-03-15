# Runa

Editor de documentos por bloques para Linux, macOS y Windows, construido con Flutter.

## Características

- **Bloques de markdown** — escribe con formato Markdown con vista previa en tiempo real, resaltado de sintaxis y soporte para fórmulas matemáticas (LaTeX).
- **Bloques de dibujo a mano** — canvas de tinta libre con herramienta de texto integrada, soporte para lápiz óptico (presión) y formas geométricas.
- **Gestión de documentos** — crea, renombra, organiza y navega documentos y carpetas desde la pantalla de inicio o la barra lateral del editor.
- **Exportación a PDF** — exporta cualquier documento a PDF conservando bloques de markdown, matemáticas e imágenes.
- **Archivos recientes** — acceso rápido a los últimos documentos abiertos.
- **Auto-guardado** — guarda cambios automáticamente con intervalo configurable.
- **Temas** — modo claro, oscuro o según el sistema.
- **Atajos de teclado** — `Ctrl+S` para guardar, `Tab` para navegar entre bloques, y más.

## Requisitos

- [Flutter](https://flutter.dev) 3.x o superior
- Dart SDK 3.11 o superior
- **Linux**: `zenity` o `kdialog` instalado (para el selector de archivos)

## Instalación y ejecución

```bash
# Clonar el repositorio
git clone <url-del-repo>
cd runa

# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run -d linux        # Linux
flutter run -d macos        # macOS
flutter run -d windows      # Windows
```

## Compilar para producción

```bash
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

## Regenerar código generado

El proyecto usa `build_runner` para generar código de Riverpod, Freezed y JSON. Si modificas modelos o notificadores:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Estructura del proyecto

```
lib/
├── application/   # Lógica de negocio: notificadores Riverpod, servicios, modelos de estado
├── data/          # Implementaciones de repositorios e I/O
├── domain/        # Modelos de dominio (Document, Block, Stroke…)
└── presentation/  # Widgets: editor, pantalla de inicio, barra lateral, ajustes
```

## Tests

```bash
flutter test
```

## Dependencias principales

| Paquete | Uso |
|---------|-----|
| `flutter_riverpod` | Gestión de estado |
| `freezed` | Modelos inmutables |
| `pdf` / `pdfrx` | Generación y visualización de PDF |
| `flutter_markdown_plus` | Renderizado de Markdown |
| `flutter_math_fork` | Fórmulas matemáticas (LaTeX) |
| `flutter_highlight` | Resaltado de sintaxis |
| `path_provider` | Directorio de documentos por defecto |

## Licencia

MIT — ver [LICENSE](LICENSE).
