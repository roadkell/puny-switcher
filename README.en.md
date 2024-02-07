In other languages: [Русский](./README.ru.md)

# Puny Switcher #

Script for correcting text typed in a wrong layout and stateless layout switching in X11 and GNOME.

## Highlights ##

- Correcting layout of a single word / line up to cursor / current selection
- Stateless layout switching: separate hotkey for each layout
- Clipboard content is preserved
- No keylogging
- No keyboard manipulation
- No modifier watching
- No key remapping
- Has alternative function implementations for non-GNOME and non-systemd environments

## Installation ##

- Install [GNOME extension](https://extensions.gnome.org/extension/6691/shyriiwook) for programmatical layout switching ([repository](https://github.com/madhead/shyriiwook)).
- Install [xsel](http://www.kfish.org/software/xsel/) for X selection and clipboard manipulation ([repository](https://github.com/kfish/xsel)).
- Install [kanata](https://github.com/jtroo/kanata/) (in particular, [`kanata_cmd_allowed`](https://github.com/jtroo/kanata/releases/latest) version that allows command execution is required) or any other keyboard remapper with support for macros and external command execution.
- Provide kanata access to input subsystem, as described [here](https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md).
- Download the [script](./puny-switcher.sh) and save it into `~/.local/bin/`. Examine its contents and modify if needed.
- Permit its execution:
```
chmod +x ~/.local/bin/puny-switcher.sh
```
- Download the [kanata configuration file](./kanata/puny-switcher.kbd) and save it into `$XDG_CONFIG_HOME/kanata/` (usually `~/.config/kanata/`). Examine and modify it if needed.
- Download the [systemd unit file](./kanata/kanata@.service) and save it into `$XDG_CONFIG_HOME/systemd/user/` (usually `~/.config/systemd/user/`) to run kanata as a service.
- Launch the service and check its status:
```
systemctl --user daemon-reload
systemctl --user enable --now kanata@puny-switcher.service
systemctl --user status kanata@puny-switcher.service
```

## Configuration ##

Default keys, as defined in [kanata configuration file](./kanata/puny-switcher.kbd):
- tap <kbd>left Shift</kbd>: switch to first layout
- tap <kbd>right Shift</kbd>: swtch to second layout
- double-tap any <kbd>Shift</kbd>: convert a single word and switch layout
- triple-tap any <kbd>Shift</kbd>: convert a line up to the cursor and switch layout
- hold <kbd>Shift</kbd>: default Shift behaviour (after a timeout)
- <kbd>Shift</kbd>+<kbd>any key</kbd>: default Shift behaviour (immediately)
- <kbd>Pause</kbd>: convert a single word and switch layout
- <kbd>Сtrl</kbd>+<kbd>Pause</kbd>: convert a line up to the cursor and switch layout
- <kbd>Shift</kbd>+<kbd>Pause</kbd>: convert selection and switch layout

They can be redefined in `defsrc` section of the config. For example, you can use <kbd>PrtSc</kbd> key instead of <kbd>Pause</kbd> by replacing `pause` with `sys`. Available key names can be found in `str_to_oscode` and `default_mappings` functions in [kanata source](https://github.com/jtroo/kanata/blob/main/parser/src/keys/mod.rs).

## Commands ##

```
puny-switcher.sh command [LAYOUT]

commands:
	get					print list of available layouts, current layout & its characters
	set LAYOUT_NAME		switch layout by name (us|ru)
	iset LAYOUT_INDEX	switch layout by index (0|1)
	switch				switch to another layout
	convert				convert selected text and store result in clipboard
	restore				restore clipboard after conversion
```

## Downsides ##

- Depends on 3rd-party software
- Doesn't work in terminal emulators yet
- Currently limited to English-Russian layout pair
- Doesn't account for layout variants (Dvorak, Typewriter, etc.) yet
- Untested in non-GNOME / non-systemd environments

## Alternatives ##

If you prefer an all-in-one solution for retyping text typed in a wrong layout, you can try [xswitcher](https://github.com/ds-voix/xswitcher). Other similar projects like `xneur` have long been abandoned. Also, most of them don't work in GNOME due to its strict security policy.

On the other hand, if you already have a favourite keyboard remapper (or just prefer a modular approach), it is likely possible that it can be set up to work with Puny Switcher script. [Here are some popular ones](https://github.com/jtroo/kanata#similar-projects). KMonad, for example, has a config file format similar to kanata. Imporantly, it must support external command execution to be able to invoke `puny-switcher.sh` with arguments. If you manage to adapt the provided config to another remapper, I'll gladly include it into the project.

GNOME is complicated in regards to programmatical layout switching. [g3kb-switch](https://github.com/lyokha/g3kb-switch) seems to be the only extension besides [Shyriiwook](https://github.com/madhead/shyriiwook) that works in GNOME 41+ at the moment. If GNOME support is not required, there is no need for an extension — `setxkbmap` command is enough. Functions named `*-nognome` in the script are alternative implementations for non-GNOME environments.

[xsel](http://www.kfish.org/software/xsel/) can be replaced with [xclip](https://github.com/astrand/xclip) for clipboard manipulation, if you prefer one over another. Just modify commands and their arguments in `puny-switcher.sh` to work with it.

Similarlly, `gdbus` command can be used instead of `busctl`, if needed: there are ready-made alternative function implementations in `puny-switcher.sh` for `gdbus`. Just modify the source to use them instead of default ones.

## Important ##

[Queer Svit](https://queersvit.org/) is a black queer-run independent team of volunteers from all over the world. With your support we help LGBTQ+ and BAME people affected by the war and/or political repressions get to safety by providing consultations, purchasing tickets, finding free accommodation and providing humanitarian aid.

‌‌Just like any other catastrophe, war affects the most those who are most vulnerable, including LGBTQ+ and BAME people while at the same time their troubles are often rendered invisible. But because our own team comprises LGBTQ+ and BAME people we see the specific challenges our beneficiaries face and understand how to help them.

‌Your donations make a difference; Queer Svit is run in large part on small donations from individual donors. We are grateful for any and all help to continue our work — thank you!

## License ##

[Hippocratic License 3.0 (HL3-CORE)](https://github.com/roadkell/puny-switcher/blob/main/LICENSE.md)
