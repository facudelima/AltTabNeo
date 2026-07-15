import Foundation

/// Configuración de marca y comportamiento de AltTabNeo.
enum AltTabNeoBranding {
    static let displayName = "AltTabNeo"
    static let bundleIdentifier = "com.alttabneo.app"
    static let author = "Facundo De Lima"
    /// Conserva copyright del proyecto upstream (GPL-3.0) y el de las modificaciones.
    static let copyright = "Copyright © 2019–2026 lwouis and contributors; modifications © 2026 Facundo De Lima."
    /// Sitio / repo público (About + appcast base).
    static let website: String? = "https://github.com/facudelima/AltTabNeo"
    static let repository: String? = "https://github.com/facudelima/AltTabNeo"
    /// Proyecto open source del que AltTabNeo es un derivado modificado (GPL-3.0).
    static let basedOnName = "AltTab"
    static let basedOnURL = "https://github.com/lwouis/alt-tab-macos"
    /// Feed Sparkle (estable en `main`); los instaladores apuntan acá para auto-update.
    static let appcastURL = "https://raw.githubusercontent.com/facudelima/AltTabNeo/main/appcast.xml"

    static let telemetryEnabled = false
    static let autoUpdateEnabled = true
    static let feedbackEnabled = false
    static let supportProjectEnabled = false
    static let proLicensingEnabled = false
    static let showDebugToolsInMenubar = false
    /// Oculta badges, textos y flujos de upgrade "Pro" en toda la UI.
    static let hideProUi = true
}

/// Todas las funciones Pro desbloqueadas en AltTabNeo.
enum AltTabNeoFreeMode {
    static var enabled: Bool { !AltTabNeoBranding.proLicensingEnabled }
}
