In other languages: [Русский](README.ru.md)

# Puny Switcher #

Script for correcting text typed in a wrong layout and stateless layout switching in X11 and GNOME.

## Highlights ##

- Stateless layout switching: separate hotkey for each layout
- Correcting layout of a single word / line up to cursor / current selection
- Clipboard content is preserved
- No keylogging
- No keyboard manipulation
- No modifier watching
- No key remapping
- Has alternative function implementations for non-GNOME / non-systemd environments

## Installation ##

- Install [GNOME extension](https://extensions.gnome.org/extension/6691/shyriiwook) for stateless layout switching by console command ([repository](https://github.com/madhead/shyriiwook)).
- Install [xsel](http://www.kfish.org/software/xsel/) for X selection and clipboard manipulation ([repository](https://github.com/kfish/xsel)).
- Install [kanata](https://github.com/jtroo/kanata/) (in particular, [`kanata_cmd_allowed`](https://github.com/jtroo/kanata/releases/latest) version that allows command execution) or any other keyboard remapper with support for macros and external command execution.
- Provide kanata access to the input and uinput subsystem, as described [here](https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md).
- Download [the script](./puny-switcher.sh) and save it into `~/.local/bin`. Examine its contents and modify if needed.
- Permit its execution:
```
chmod +x ~/.local/bin/puny-switcher.sh
```
- Download [the kanata configuration file](./kanata/puny-switcher.kbd) and save it into `$XDG_CONFIG_HOME/kanata/` (usually `~/.config/kanata/`). Examine and modify it if needed.
- Download [the systemd unit file](./kanata/kanata@.service) and save it into `$XDG_CONFIG_HOME/systemd/user/` (usually `~/.config/systemd/user/`) to run kanata as a service.
- Launch the service and check its status:
```
systemctl --user daemon-reload
systemctl --user enable --now kanata@puny-switcher.service
systemctl --user status kanata@puny-switcher.service
```
- The script also uses `busctl` command (part of systemd), `sed` and `grep`.

## Configuration ##

TODO

## Downsides ##

- Depends on 3rd-party software
- Doesn't work in terminal emulators yet
- Currently limited to English-Russian layout pair
- Doesn't account for layout variants (Dvorak, Typewriter, etc.) yet
- Untested in non-GNOME / non-systemd environments

## Important ##

[Queer Svit](https://queersvit.org/) is a black queer-run independent team of volunteers from all over the world. With your support we help LGBTQ+ and BAME people affected by the war and/or political repressions get to safety by providing consultations, purchasing tickets, finding free accommodation and providing humanitarian aid.

‌‌Just like any other catastrophe, war affects the most those who are most vulnerable, including LGBTQ+ and BAME people while at the same time their troubles are often rendered invisible. But because our own team comprises LGBTQ+ and BAME people we see the specific challenges our beneficiaries face and understand how to help them.

‌Your donations make a difference; Queer Svit is run in large part on small donations from individual donors. We are grateful for any and all help to continue our work — thank you!

## License ##

[Hippocratic License 3.0 (HL3-CORE)](https://github.com/roadkell/puny-switcher/blob/main/LICENSE.md)
