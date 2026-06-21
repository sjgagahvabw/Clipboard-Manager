# Clipboard Manager

**Historial de portapapeles minimalista y elegante para tu Mac.**

Una aplicación nativa en la barra de menú que recuerda todo lo que copias.  
Sin icono en el Dock, sin distracciones — solo un icono de portapapeles en la barra de menú.

## Características

- **Captura automática** — cada `Cmd+C` se guarda al instante
- **Búsqueda** — filtra cientos de elementos en milisegundos
- **Fijar** — mantén fragmentos importantes para siempre
- **Limpieza automática** — los elementos no fijados desaparecen después de 1 hora
- **Aspecto nativo** — vibrancia, animaciones, modo oscuro/claro
- **Privacidad primero** — todo se almacena localmente

## Uso

Haz clic en el icono del portapapeles en la barra de menú → verás tu historial → haz clic en cualquier elemento para copiarlo de nuevo.

| Acción | Resultado |
|---|---|
| Clic en elemento | Copiar al portapapeles |
| Icono de chincheta | Fijar elemento permanentemente |
| Icono de cruz | Eliminar elemento |
| Campo de búsqueda | Filtrar historial |

## Instalación

```bash
git clone https://github.com/sjgagahvabw/clipboard-manager.git
cd clipboard-manager
make run
```

O abre el proyecto en Xcode y presiona Run.

## Compilar

```bash
make        # compilar + empaquetar .app
make run    # ejecutar
make clean  # eliminar archivos de compilación
```

Sin dependencias. Sin gestores de paquetes. Solo Swift.

## Icono

La aplicación vive en la barra de menú (esquina superior derecha).  
**No** aparece en el Dock.

## Licencia

MIT
