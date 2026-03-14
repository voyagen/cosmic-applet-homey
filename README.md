# COSMIC Applet Homey

A minimal COSMIC panel applet that opens the Homey dashboard at `https://my.homey.app/`.

The applet adds a Homey button to the COSMIC panel. Clicking it opens the Homey web app in your default browser.

## Requirements

- COSMIC Desktop
- Rust and Cargo
- `just`

## Install

```bash
just install
```

After installing, restart the COSMIC panel or log out and back in, then add `Homey` from COSMIC Settings -> Desktop -> Panel or Dock.

## Development

```bash
just build
just run
just install
just uninstall
```

## Notes

- This applet is intended for COSMIC and will not appear in standard app launchers because its desktop file is marked `NoDisplay=true`.
- The panel icon is embedded from `icon.png` so the button remains visible even if the desktop icon cache is stale.

## License

MIT
