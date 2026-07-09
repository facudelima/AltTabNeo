import Foundation

/// Configuración de marca y comportamiento de AltTabNeo.
enum AltTabNeoBranding {
    static let displayName = "AltTabNeo"
    static let bundleIdentifier = "com.alttabneo.app"
    static let author = "Facundo De Lima"
    static let copyright = "Copyright © 2026 Facundo De Lima."
    /// Sitio propio; nil oculta el enlace en About.
    static let website: String? = nil
    static let repository: String? = "https://github.com/facudelima/AltTabNeo"

    static let telemetryEnabled = false
    static let autoUpdateEnabled = false
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
