app_id := "com.github.cosmic-applet-homey"
bin_name := "cosmic-applet-homey"
desktop_file := "data/com.github.cosmic-applet-homey.desktop"
icon_file := "icon.png"

build:
    cargo build

release:
    cargo build --release

run:
    cargo run

install: release
    install -Dm755 target/release/{{bin_name}} ~/.local/bin/{{bin_name}}
    install -Dm644 {{desktop_file}} ~/.local/share/applications/{{app_id}}.desktop
    install -Dm644 {{icon_file}} ~/.local/share/icons/hicolor/512x512/apps/{{app_id}}.png

uninstall:
    rm -f ~/.local/bin/{{bin_name}}
    rm -f ~/.local/share/applications/{{app_id}}.desktop
    rm -f ~/.local/share/icons/hicolor/512x512/apps/{{app_id}}.png
