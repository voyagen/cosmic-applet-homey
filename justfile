app_id := "com.github.cosmic-applet-homey"
bin_name := "cosmic-applet-homey"
desktop_file := "data/com.github.cosmic-applet-homey.desktop"
icon_file := "icon.png"
icon_svg := "data/icons/scalable/apps/com.github.cosmic-applet-homey.svg"
icon_symbolic := "data/icons/scalable/apps/com.github.cosmic-applet-homey-symbolic.svg"

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
    install -Dm644 {{icon_svg}} ~/.local/share/icons/hicolor/scalable/apps/{{app_id}}.svg
    install -Dm644 {{icon_symbolic}} ~/.local/share/icons/hicolor/scalable/apps/{{app_id}}-symbolic.svg
    install -Dm644 {{icon_svg}} ~/.local/share/icons/hicolor/scalable/status/{{app_id}}.svg
    install -Dm644 {{icon_symbolic}} ~/.local/share/icons/hicolor/scalable/status/{{app_id}}-symbolic.svg

uninstall:
    rm -f ~/.local/bin/{{bin_name}}
    rm -f ~/.local/share/applications/{{app_id}}.desktop
    rm -f ~/.local/share/icons/hicolor/512x512/apps/{{app_id}}.png
    rm -f ~/.local/share/icons/hicolor/scalable/apps/{{app_id}}.svg
    rm -f ~/.local/share/icons/hicolor/scalable/apps/{{app_id}}-symbolic.svg
    rm -f ~/.local/share/icons/hicolor/scalable/status/{{app_id}}.svg
    rm -f ~/.local/share/icons/hicolor/scalable/status/{{app_id}}-symbolic.svg
