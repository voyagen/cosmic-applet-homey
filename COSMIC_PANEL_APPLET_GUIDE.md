# Building a COSMIC Panel Applet on Fedora 43

This guide is based on the current `libcosmic` applet documentation and Fedora 43 package availability as of March 14, 2026.

## What a COSMIC applet is

A COSMIC panel applet is a normal Rust GUI process built with `libcosmic`, but launched by `cosmic-panel` and embedded into the panel or dock. The panel discovers applets through their `.desktop` files, and applet popups are separate windows managed through COSMIC's popup APIs.

The main differences from a regular `libcosmic` app are:

- You run it with `cosmic::applet::run(...)` instead of `cosmic::app::run(...)`.
- You enable the `applet` Cargo feature on `libcosmic`.
- You usually render a compact panel button for the main view.
- You define popup windows explicitly.
- You must install a `.desktop` file with COSMIC-specific keys so the panel can find it.

## Fedora 43 dependencies

Install the common build dependencies:

```bash
sudo dnf install rust cargo cmake just \
  fontconfig-devel freetype-devel expat-devel \
  libxkbcommon-devel pkgconf-pkg-config
```

If your build ends up pulling X11-specific pieces, also install:

```bash
sudo dnf install libxkbcommon-x11-devel
```

Optional but useful:

```bash
cargo install cargo-generate
```

## Recommended starting point

The official `cosmic-app-template` is the best bootstrap point, even though it is app-focused rather than applet-specific:

```bash
cargo generate gh:pop-os/cosmic-app-template
```

After generating the project, convert it from an app into an applet using the changes below.

## Minimal project layout

You will usually want at least:

```text
my-applet/
├── Cargo.toml
├── src/main.rs
├── data/com.example.MyApplet.desktop
└── res/com.example.MyApplet-symbolic.svg
```

## `Cargo.toml`

Use `libcosmic` with the `applet` feature enabled. For panel applets, people commonly avoid `wgpu` unless they specifically want GPU rendering.

```toml
[package]
name = "my-cosmic-applet"
version = "0.1.0"
edition = "2021"

[dependencies]
libcosmic = { git = "https://github.com/pop-os/libcosmic", default-features = false, features = ["applet", "tokio"] }
```

Notes:

- `libcosmic` moves quickly, so many COSMIC projects track Git rather than crates.io releases.
- If you hit feature mismatches, compare with a current System76 COSMIC applet or `libcosmic` example before debugging your own code.

## Minimal `src/main.rs`

This is the basic shape of an applet: store `cosmic::Core`, render a small button in the panel, and open a popup on click.

```rust
use cosmic::app::{Core, Task};
use cosmic::iced::{window, Limits};
use cosmic::widget;
use cosmic::{Application, Element};

fn main() -> cosmic::iced::Result {
    cosmic::applet::run::<Applet>(())
}

struct Applet {
    core: Core,
    popup: Option<window::Id>,
}

#[derive(Clone, Debug)]
enum Message {
    TogglePopup,
}

impl Application for Applet {
    type Executor = cosmic::executor::Default;
    type Flags = ();
    type Message = Message;

    const APP_ID: &'static str = "com.example.MyApplet";

    fn init(core: Core, _flags: Self::Flags) -> (Self, Task<Self::Message>) {
        (
            Self {
                core,
                popup: None,
            },
            Task::none(),
        )
    }

    fn core(&self) -> &Core {
        &self.core
    }

    fn core_mut(&mut self) -> &mut Core {
        &mut self.core
    }

    fn update(&mut self, message: Self::Message) -> Task<Self::Message> {
        match message {
            Message::TogglePopup => {
                if let Some(id) = self.popup.take() {
                    cosmic::iced::platform_specific::shell::commands::popup::destroy_popup(id)
                } else {
                    let new_id = window::Id::unique();
                    self.popup = Some(new_id);

                    let mut settings = self.core.applet.get_popup_settings(
                        self.core.main_window_id().unwrap(),
                        new_id,
                        Some((320, 180)),
                        None,
                        None,
                    );

                    settings.positioner.size_limits = Limits::NONE
                        .min_width(220.0)
                        .min_height(80.0)
                        .max_width(420.0)
                        .max_height(320.0);

                    cosmic::iced::platform_specific::shell::commands::popup::get_popup(settings)
                }
            }
        }
    }

    fn view(&self) -> Element<Self::Message> {
        self.core
            .applet
            .icon_button("system-search-symbolic")
            .on_press_down(Message::TogglePopup)
            .into()
    }

    fn view_window(&self, id: window::Id) -> Element<Self::Message> {
        if self.popup == Some(id) {
            self.core
                .applet
                .popup_container(widget::text("Hello from COSMIC"))
                .into()
        } else {
            widget::text("").into()
        }
    }

    fn style(&self) -> Option<cosmic::iced_runtime::Appearance> {
        Some(cosmic::applet::style())
    }
}
```

What matters here:

- `cosmic::applet::run::<Applet>(())` is the applet entrypoint.
- `view()` is the small panel-facing UI.
- `view_window()` renders the popup content.
- `style()` should return `cosmic::applet::style()` so the panel-facing window gets the right transparent appearance.

## Desktop entry requirements

Your applet will not show up properly in COSMIC settings or the panel picker without the right `.desktop` file metadata.

Example `data/com.example.MyApplet.desktop`:

```ini
[Desktop Entry]
Name=My Applet
Type=Application
Exec=my-cosmic-applet
Terminal=false
Categories=COSMIC;
Keywords=COSMIC;Applet;
Icon=com.example.MyApplet-symbolic
StartupNotify=true
NoDisplay=true
X-CosmicApplet=true
X-CosmicHoverPopup=Auto
X-OverflowPriority=10
```

Important fields:

- `X-CosmicApplet=true`: tells COSMIC this desktop entry is a panel applet.
- `NoDisplay=true`: keeps it out of normal app launchers.
- `X-CosmicHoverPopup=Auto`: enables COSMIC hover-popup behavior when appropriate.
- `Exec=`: must point to a working installed binary. If panel discovery works but launch fails, this line is a common cause.

## Install locally for testing

For local user testing, install the binary, desktop file, and icon into your home directory:

```bash
cargo build --release
install -Dm755 target/release/my-cosmic-applet ~/.local/bin/my-cosmic-applet
install -Dm644 data/com.example.MyApplet.desktop ~/.local/share/applications/com.example.MyApplet.desktop
install -Dm644 res/com.example.MyApplet-symbolic.svg ~/.local/share/icons/hicolor/scalable/apps/com.example.MyApplet-symbolic.svg
```

Then:

1. Open COSMIC Settings.
2. Go to Desktop, then Panel or Dock.
3. Add the applet.

If it does not appear immediately, log out and back in, or restart the relevant user session components.

## Development loop

Typical loop:

```bash
cargo check
cargo build
cargo run
```

For real panel testing, you usually need the installed binary and desktop file, because launching with `cargo run` alone does not validate panel discovery.

## Packaging notes

Most existing COSMIC applets ship with a `justfile` that wraps:

- build
- install
- uninstall
- RPM or DEB packaging

On Fedora, RPM packaging is the natural direction. For a first pass, get the user-local install working before adding an RPM spec or generating system packages.

## Practical advice

- Start with a tiny icon-button applet and one popup.
- Keep panel UI minimal; put real content in the popup.
- Use symbolic icons so the applet fits the desktop theme.
- Expect `libcosmic` APIs to change; use current examples when compiler errors look surprising.
- If you want persistence, add configuration only after the panel integration works.

## Common failure cases

### Applet does not appear in COSMIC Settings

Check:

- The desktop file is installed into `~/.local/share/applications/` or `/usr/share/applications/`.
- `X-CosmicApplet=true` is spelled exactly.
- `NoDisplay=true` is present.
- The desktop filename and app ID are sane and consistent.

### Applet appears but does not launch

Check:

- `Exec=` actually starts the binary.
- The binary is installed in a path visible to the session.
- Running the same command manually works.

### Popup behavior is broken

Check:

- You create the popup using `self.core.applet.get_popup_settings(...)`.
- You render popup content in `view_window()`.
- You destroy old popup IDs before creating a new one.

### Build fails on Fedora

Check for missing native deps first:

- `fontconfig-devel`
- `freetype-devel`
- `expat-devel`
- `libxkbcommon-devel`
- sometimes `libxkbcommon-x11-devel`

## Suggested next step for this repo

If you want, the next useful move is to turn this repository into a minimal working applet with:

- a `Cargo.toml`
- a tiny `src/main.rs`
- a desktop file
- a symbolic icon
- a local install script or `justfile`

## Sources

- `libcosmic` book, Panel Applets: https://pop-os.github.io/libcosmic-book/panel-applets.html
- `libcosmic` book, Introduction: https://pop-os.github.io/libcosmic-book/
- `libcosmic` repository: https://github.com/pop-os/libcosmic
- COSMIC panel repository: https://github.com/pop-os/cosmic-panel
- Fedora 43 package info:
  - `just`: https://packages.fedoraproject.org/pkgs/rust-just/just/
  - `fontconfig-devel`: https://packages.fedoraproject.org/pkgs/fontconfig/fontconfig-devel
  - `freetype-devel`: https://packages.fedoraproject.org/pkgs/freetype/freetype-devel
  - `expat-devel`: https://packages.fedoraproject.org/pkgs/expat/expat-devel
  - `libxkbcommon-devel`: https://packages.fedoraproject.org/pkgs/libxkbcommon/libxkbcommon-devel
  - `libxkbcommon-x11-devel`: https://packages.fedoraproject.org/pkgs/libxkbcommon/libxkbcommon-x11-devel
