import Foundation

/// Configuración del fork personal AltTabX (sin pagos ni servicios del upstream).
enum AltTabXBranding {
    static let isPersonalFork = true

    static let displayName = "AltTabX"
    static let bundleIdentifier = "com.alttabx.app"
    static let author = "Facundo De Lima"
    static let copyright = "Copyright © 2026 Facundo De Lima."
    /// Sitio propio; nil oculta el enlace en About.
    static let website: String? = nil
    static let repository: String? = "https://github.com/facudelima"

    // Funciones desactivadas respecto al upstream
    static let telemetryEnabled = false
    static let autoUpdateEnabled = false
    static let upstreamFeedbackEnabled = false
    static let supportProjectEnabled = false
    static let proLicensingEnabled = false
    static let showDebugToolsInMenubar = false
    /// Oculta badges, textos y flujos de upgrade "Pro" en toda la UI.
    static let hideProUi = true
}

/// Compat con parches existentes.
enum AltTabXFreeMode {
    static var enabled: Bool { AltTabXBranding.isPersonalFork && !AltTabXBranding.proLicensingEnabled }
}
