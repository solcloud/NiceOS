## Presets

NiceOS can build completely different target image based on set of rules called __preset__. Before building you are required to select one preset using `NICE_PRESET` variable.

Here are some inlcuded presets:
- __[base](base/)__ - starting template, testing preset, [github action](https://github.com/solcloud/NiceOS/actions/workflows/test.yml)
- __[dev](dev/)__ - my development environment featuring docker, [youtube](https://youtu.be/cPaDJTJbgwQ)
- __[ghost](ghost/)__ - my main desktop machine, [youtube](https://youtu.be/SNuNFt7kSIE)
- __[leti](leti/)__ - my laptop machine
- __[minimal](minimal/)__ - simple & fast ram disk only + kernel + busybox binaries, but you can add anything to it of course, use ldd or static, [youtube](https://youtu.be/4CH8b0HnIu8)

Of course user can provide [own preset](https://github.com/solcloud/NiceOS#users-presets) using `NICE_PRESET_ROOT` variable.
