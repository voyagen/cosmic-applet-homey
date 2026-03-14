mod window;

use window::Window;

const VERSION: &str = env!("CARGO_PKG_VERSION");

fn main() -> cosmic::iced::Result {
    tracing_subscriber::fmt::init();
    let _ = tracing_log::LogTracer::init();

    tracing::info!("Starting cosmic-applet-homey v{VERSION}");

    cosmic::applet::run::<Window>(())
}
