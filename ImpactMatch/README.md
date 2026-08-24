# ImpactMatch — Proyecto SwiftUI

App para conectar personas con empresas/organizaciones mediante un sistema de
compatibilidad (matching) explicable, alineada al **ODS 17: Alianzas para
lograr los objetivos**.

## Cómo abrirlo en Xcode

Estos son archivos fuente (no un `.xcodeproj`, porque eso solo se puede
generar correctamente desde Xcode). Para importarlos:

1. Abre Xcode → **File > New > Project… > iOS > App**.
2. Nómbralo **ImpactMatch**, interfaz **SwiftUI**, lenguaje **Swift**.
   Guárdalo donde quieras.
3. Xcode crea automáticamente `ImpactMatchApp.swift` y `ContentView.swift`.
   **Borra `ContentView.swift`** (no se usa) y **reemplaza** el
   `ImpactMatchApp.swift` que generó Xcode por el de esta carpeta.
4. En el navegador de Xcode, clic derecho sobre el grupo `ImpactMatch` →
   **Add Files to "ImpactMatch"…** → selecciona las carpetas `Core`,
   `Components` y `Views` de este proyecto (con "Create groups" marcado).
5. Compila con `Cmd + R` en un simulador de iPhone.

## Estructura

```
ImpactMatch/
├── ImpactMatchApp.swift        # Punto de entrada, alterna login/app
├── Core/
│   ├── Theme.swift             # Colores, tipografía, estilos de botón/card
│   ├── Models.swift            # UserProfile, Opportunity, Match, Connection...
│   ├── AppStore.swift          # Estado global + motor de matching explicable
│   └── MockData.swift          # Datos de ejemplo para la demo escolar
├── Components/
│   ├── CompatibilityBadge.swift
│   ├── OpportunityCard.swift
│   └── StatCard.swift
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
        ├── ProfileView.swift
        └── SettingsView.swift
```

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

Incluye: splash, login, registro con selección de tipo de usuario, perfil,
explorar oportunidades con filtros y buscador, crear oportunidad, detalle
con matching explicado, solicitar/aplicar, conexiones, y estadísticas de
impacto.

Quedan para v2 (mencionado en tu planteamiento): chat, notificaciones,
mapas, sistema de reputación, matching con IA, backend real.
