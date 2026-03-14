use cosmic::app::Core;
use cosmic::widget::icon;
use cosmic::Element;

const APP_ID: &str = "com.github.cosmic-applet-homey";
const HOMEY_URL: &str = "https://my.homey.app/";
const ICON_BYTES: &[u8] = include_bytes!(concat!(env!("CARGO_MANIFEST_DIR"), "/icon.png"));

#[derive(Debug, Clone)]
pub enum Message {
    OpenHomey,
    Surface(cosmic::surface::Action),
}

pub struct Window {
    core: Core,
}

impl cosmic::Application for Window {
    type Executor = cosmic::executor::Default;
    type Flags = ();
    type Message = Message;
    const APP_ID: &'static str = APP_ID;

    fn core(&self) -> &Core {
        &self.core
    }

    fn core_mut(&mut self) -> &mut Core {
        &mut self.core
    }

    fn init(core: Core, _flags: Self::Flags) -> (Self, cosmic::app::Task<Self::Message>) {
        (Self { core }, cosmic::app::Task::none())
    }

    fn update(&mut self, message: Self::Message) -> cosmic::app::Task<Self::Message> {
        match message {
            Message::OpenHomey => {
                if let Err(e) = open::that_detached(HOMEY_URL) {
                    tracing::error!("Failed to open browser: {e}");
                }
                cosmic::app::Task::none()
            }
            Message::Surface(action) => {
                cosmic::task::message(cosmic::Action::Cosmic(
                    cosmic::app::Action::Surface(action),
                ))
            }
        }
    }

    fn view(&self) -> Element<'_, Self::Message> {
        let icon_handle = icon::from_raster_bytes(ICON_BYTES);
        let button = self
            .core
            .applet
            .icon_button_from_handle(icon_handle)
            .on_press(Message::OpenHomey);

        Element::from(self.core.applet.applet_tooltip::<Message>(
            button,
            "Homey",
            false,
            |a| Message::Surface(a),
            None,
        ))
    }

    fn style(&self) -> Option<cosmic::iced::theme::Style> {
        Some(cosmic::applet::style())
    }
}
