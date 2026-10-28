import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Customises the screen people see when they open a paused app during wind-down.
final class WindDownShieldConfiguration: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        windDownShield(appName: application.localizedDisplayName)
    }

    override func configuration(shielding application: Application,
                                in category: ActivityCategory) -> ShieldConfiguration {
        windDownShield(appName: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        windDownShield(appName: webDomain.domain)
    }

    override func configuration(shielding webDomain: WebDomain,
                                in category: ActivityCategory) -> ShieldConfiguration {
        windDownShield(appName: webDomain.domain)
    }

    private func windDownShield(appName: String?) -> ShieldConfiguration {
        let name = appName ?? "This app"
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.6),
            icon: UIImage(systemName: "moon.stars.fill"),
            title: ShieldConfiguration.Label(text: "It's wind-down time", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "\(name) will be here in the morning. Take a breath instead.",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: .systemIndigo
        )
    }
}
