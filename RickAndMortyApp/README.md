# Rick and Morty App

App nativa iOS que permite explorar personajes de la serie *Rick and Morty*, ver detalles, gestionar favoritos, marcar episodios vistos y visualizar ubicaciones en un mapa.

## Features

### Personajes
- Lista con paginación
- Búsqueda por nombre
- Filtros por estado y especie
- Pull to refresh
- Estados de carga, vacío y error

### Detalle del personaje
- Información completa (nombre, especie, estado, género, ubicación)
- Lista de episodios
- Marcar episodios como vistos
- Agregar/quitar favoritos
- Ver ubicación en mapa

### Favoritos
- Lista de personajes guardados
- Acceso protegido con Face ID / biometría

### Mapa
- Visualización de ubicaciones simuladas
- Pines interactivos con nombre y ubicación


## Arquitectura

- MVVM + Clean Architecture
- Separación por capas:
  - Domain
  - Data
  - Presentation
- Uso de protocolos para desacoplamiento
- Persistencia con Core Data
- Inyección de dependencias manual


## Persistencia

Se almacena localmente:

- Personajes favoritos
- Estado de episodios vistos
- Información básica de personajes



## Seguridad

- Autenticación biométrica (Face ID / Touch ID) para acceder a favoritos


## Testing

- Unit tests en ViewModel
- Mocks para casos de uso
- UI test de flujo principal (listado → detalle → favorito)


## Requisitos

- Xcode 15+
- iOS 15+
- Swift 5.9+

## Instalación y ejecución

### 1. Clonar repositorio

```bash
git clone https://github.com/adrian220699/RickAndMortyApp.git
```

### 2. Abrir proyecto

```bash
cd RickAndMortyApp
open RickAndMortyApp.xcodeproj
```

### 3. Ejecutar la app

- Selecciona un simulador o dispositivo físico en Xcode  
- Presiona ▶ Run

---

## Ejecutar tests

### Desde Xcode
```
Cmd + U
```

### Desde terminal

```bash
xcodebuild test -scheme RickAndMortyApp
```

---

## Estructura del proyecto

```text
Core/
Data/
Domain/
Presentation/
Protocols/
```

---

## Autor

Adrian Flores Herrera — Prueba tecnica iOS developer.



