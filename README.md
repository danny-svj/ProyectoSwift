# ImpactMatch — Proyecto SwiftUI

App para conectar personas con empresas/organizaciones mediante un sistema de
compatibilidad (matching) explicable, alineada al **ODS 17: Alianzas para
lograr los objetivos**.

## Cómo abrirlo en Xcode

Ya existe un proyecto real: **`ImpactMatch.xcodeproj`** en la raíz de esta
carpeta. Solo hace falta:

1. Doble clic en `ImpactMatch.xcodeproj` (se abre en Xcode).
2. Elige un simulador de iPhone arriba a la izquierda.
3. `Cmd + R` para correr, o `Cmd + B` para solo compilar.

No hay que crear un proyecto nuevo ni arrastrar archivos — eso ya está
hecho. Si en algún momento agregas o quitas archivos `.swift` fuera de
Xcode (por ejemplo editándolos por fuera), corre esto desde la raíz para
regenerar el `.xcodeproj` y que los vea:

```bash
brew install xcodegen   # una sola vez
xcodegen generate
```

El proyecto se describe en `project.yml` — esa es la fuente de verdad,
no el `.xcodeproj` (que es generado y no se debe editar a mano).

## Estructura

```
ImpactMatch/
├── ImpactMatchApp.swift        # Punto de entrada, alterna login/app
├── Core/
│   ├── Theme.swift             # Colores, tipografía, estilos de botón/card
│   ├── Models.swift            # UserProfile, Opportunity, Match, Connection...
│   ├── AppStore.swift          # Estado global + motor de matching explicable
│   └── MockData.swift          # Datos de ejemplo para la demo escolar
│   ├── LocationManager.swift    # Envoltorio de CoreLocation para el mapa
│   └── MockData.swift          # Datos de ejemplo para la demo escolar
├── Components/
│   ├── CompatibilityBadge.swift
│   ├── OpportunityCard.swift
│   ├── StatCard.swift
│   └── TagSelector.swift       # Selector de chips para habilidades/intereses
└── Views/
    ├── Onboarding/
    │   ├── SplashView.swift
    │   ├── LoginView.swift
    │   ├── UserTypeSelectionView.swift
    │   └── SignUpView.swift
    └── Main/
        ├── MainTabView.swift
        ├── HomeView.swift
        ├── ExploreView.swift
        ├── OpportunityDetailView.swift
        ├── CreateOpportunityView.swift
        ├── ConnectionsView.swift
        ├── ImpactStatsView.swift
        ├── NearMeView.swift        # Mapa "Cerca de mí" (personas y organizaciones)
        ├── ProfileEditorView.swift # Armar perfil (registro) y editarlo después
        ├── ProfileView.swift
        └── SettingsView.swift
```

## Perfil: habilidades antes de crear la cuenta

Al registrarte, después de nombre/correo/contraseña pasas por
`ProfileEditorView` (modo `.create`) **antes** de que la cuenta se cree de
verdad: eliges tus habilidades e intereses (de una lista sugerida en
`SkillCatalog` o escribiendo las tuyas), tu disponibilidad y modalidad
preferida. Esos datos son justo lo que usa `MatchEngine`, así que desde el
primer match el porcentaje es real y no genérico.

Puedes editar todo esto después desde **Perfil → ícono de lápiz**, que abre
la misma vista en modo `.edit`.

## Mapa "Cerca de mí"

Desde **Explorar → ícono de mapa** se abre `NearMeView`: un mapa (MapKit)
con personas y organizaciones cercanas. Usa tu ubicación real si das
permiso (pide `NSLocationWhenInUseUsageDescription`); si no, centra en una
ubicación por defecto para que la demo funcione igual. Como no hay backend
de geolocalización real, las posiciones son simuladas alrededor del centro
(`NearbyEntity.mockNearby` en `MockData.swift`) — el patrón queda listo
para conectarse a datos reales más adelante.

## Cómo funciona el matching (explicable, no inventado)

`MatchEngine` en `AppStore.swift` calcula 4 sub-puntajes comparando el
perfil del usuario contra la oportunidad, y los combina con los pesos que
definiste en el planteamiento del proyecto:

| Factor         | Peso | Cómo se calcula                                              |
|----------------|------|---------------------------------------------------------------|
| Habilidades    | 50%  | % de habilidades requeridas que el usuario también tiene       |
| Intereses      | 20%  | % de intereses de la oportunidad que coinciden con el usuario  |
| Disponibilidad | 15%  | Horas/semana disponibles del usuario                           |
| Modalidad      | 15%  | Coincide modalidad preferida vs. la de la oportunidad           |

El resultado se muestra desglosado en `OpportunityDetailView`, no solo como
un número — así el porcentaje es explicable, como pediste.

## Datos y backend

Todo corre con datos mock en memoria (`MockData.swift`) — no hay
almacenamiento persistente ni Firebase todavía. Los modelos ya son
`Codable`, así que conectar Firebase/Firestore más adelante (para v2) es
directo: reemplazarías `AppStore` por una versión que lea/escriba de
Firestore en vez de arrays en memoria, sin tocar las vistas.

## Alcance de esta versión (v1, escolar)

Incluye: splash, login, registro con selección de tipo de usuario y
armado de perfil (habilidades, intereses, disponibilidad, modalidad)
antes de crear la cuenta, edición de perfil, explorar oportunidades con
filtros y buscador, mapa de personas/organizaciones cerca de ti, crear
oportunidad, detalle con matching explicado, solicitar/aplicar,
conexiones, y estadísticas de impacto.

Quedan para v2 (mencionado en tu planteamiento): chat, notificaciones,
geolocalización real de otros usuarios (hoy es simulada), sistema de
reputación, matching con IA, backend real.
