## Puny Switcher ##

Small script for correcting text typed in a wrong layout (aka Punto-switching) and layout switching by console command in X11 and GNOME.

### Highlights ###

- Stateless layout switching
- Correcting layout of a single word / line up to cursor / current selection
- Clipboard content is preserved
- No keylogging
- No keyboard manipulation
- No modifier watching
- No key remapping
- Fast enough to be almost non-intrusive

### Requirements ###

- [GNOME extension](https://extensions.gnome.org/extension/6691/shyriiwook) for layout switching by console command ([repository](https://github.com/madhead/shyriiwook))
- [`kanata`](https://github.com/jtroo/kanata/) or any other keyboard remapper with support for macros and shell command invocation
- [`xsel`](http://www.kfish.org/software/xsel/) for X selection and clipboard manipulation ([repository](https://github.com/kfish/xsel))
- `gdbus` to switch between layouts (likely already installed on your system)
- `sed`, `grep`, `bash`

### Downsides ###

- Depends on 3rd-party software
- Doesn't work in terminal emulators yet
- Currently limited to English-Russian layout pair
- Doesn't account for layout variants yet
- Untested in non-GNOME environments

### Important ###

[Queer Svit](https://queersvit.org/) is a black queer-run independent team of volunteers from all over the world. With your support we help LGBTQ+ and BAME people affected by the war and/or political repressions get to safety by providing consultations, purchasing tickets, finding free accommodation and providing humanitarian aid.

‌‌Just like any other catastrophe, war affects the most those who are most vulnerable, including LGBTQ+ and BAME people while at the same time their troubles are often rendered invisible. But because our own team comprises LGBTQ+ and BAME people we see the specific challenges our beneficiaries face and understand how to help them.

‌Your donations make a difference; Queer Svit is run in large part on small donations from individual donors. We are grateful for any and all help to continue our work — thank you!

### License ###

[Hippocratic License 3.0 (HL3-CORE)](https://github.com/roadkell/puny-switcher/blob/main/LICENSE.md)
