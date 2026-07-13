import Foundation

/// Configuración de marca y comportamiento de AltTabX.
enum AltTabXBranding {
    static let displayName = "AltTabX"
    static let bundleIdentifier = "com.alttabx.app"
    static let author = "Facundo De Lima"
    static let copyright = "Copyright © 2026 Facundo De Lima."
    /// Sitio propio; nil oculta el enlace en About.
    static let website: String? = nil
    static let repository: String? = "https://github.com/facudelima/AltTabX"

    static let telemetryEnabled = false
    static let autoUpdateEnabled = false
    static let feedbackEnabled = false
    static let supportProjectEnabled = false
    static let proLicensingEnabled = false
    static let showDebugToolsInMenubar = false
    /// Oculta badges, textos y flujos de upgrade "Pro" en toda la UI.
    static let hideProUi = true
}

/// Todas las funciones Pro desbloqueadas en AltTabX.
enum AltTabXFreeMode {
    static var enabled: Bool { !AltTabXBranding.proLicensingEnabled }
}
