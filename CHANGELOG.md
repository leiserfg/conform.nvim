# Changelog

## [3.2.0](https://github.com/stevearc/conform.nvim/compare/v3.1.0...v3.2.0) (2023-09-14)


### Features

* add `markdownlint`, `stylelint`, `codespell`, and `biome` ([#45](https://github.com/stevearc/conform.nvim/issues/45)) ([580ab18](https://github.com/stevearc/conform.nvim/commit/580ab1880e740f4aebbc72a05350461f3cdef53d))
* add buf as protobuf linter ([#43](https://github.com/stevearc/conform.nvim/issues/43)) ([2b73887](https://github.com/stevearc/conform.nvim/commit/2b73887fd75e1f6efc352cec6bd7e39157c3732e))
* add deno fmt ([#46](https://github.com/stevearc/conform.nvim/issues/46)) ([db7461a](https://github.com/stevearc/conform.nvim/commit/db7461afcf751023adeb346d833f2e5d40a420c4))
* add djlint ([#47](https://github.com/stevearc/conform.nvim/issues/47)) ([ead0257](https://github.com/stevearc/conform.nvim/commit/ead025784c8e31b8e45016e620c2f17a13ff741a))
* latexindent ([#42](https://github.com/stevearc/conform.nvim/issues/42)) ([502a358](https://github.com/stevearc/conform.nvim/commit/502a3583663ede11c8db1e9980db342b117d79f2))
* ruff ([#41](https://github.com/stevearc/conform.nvim/issues/41)) ([fdc4a0f](https://github.com/stevearc/conform.nvim/commit/fdc4a0f05c21012f2445a993ebdad700380dcfbf))


### Bug Fixes

* extra trailing newline for LSP formatters that replace entire file ([e18cdaf](https://github.com/stevearc/conform.nvim/commit/e18cdaf529b94465592d0c2afe1b62bc26155070))

## [3.1.0](https://github.com/stevearc/conform.nvim/compare/v3.0.0...v3.1.0) (2023-09-13)


### Features

* format_on_save and format_after_save can be functions ([dd5b2f2](https://github.com/stevearc/conform.nvim/commit/dd5b2f2f7ca01c2f28239cbbc7f97e6f9024cd94))


### Bug Fixes

* modify diff calculation to handle end-of-file newlines better ([#35](https://github.com/stevearc/conform.nvim/issues/35)) ([00a5288](https://github.com/stevearc/conform.nvim/commit/00a528818463b10d84699b2e0f4a960d5a4aeb5c))

## [3.0.0](https://github.com/stevearc/conform.nvim/compare/v2.3.0...v3.0.0) (2023-09-08)


### ⚠ BREAKING CHANGES

* remove run_all_formatters config option

### Features

* add beautysh, taplo, trim_newlines and trim_whitespace ([#29](https://github.com/stevearc/conform.nvim/issues/29)) ([37a2d65](https://github.com/stevearc/conform.nvim/commit/37a2d65bd2ee41540cc426d2cffef6d6f8648357))
* format() can always fall back to LSP formatting ([c3028b3](https://github.com/stevearc/conform.nvim/commit/c3028b327bc44335cc2b5c3014cd6d5c12a54ee4))
* syntax for using first available formatter ([2568d74](https://github.com/stevearc/conform.nvim/commit/2568d746abbadf66a03c62b568ee73d874cd8617))


### Code Refactoring

* remove run_all_formatters config option ([bd1aa02](https://github.com/stevearc/conform.nvim/commit/bd1aa02ef191410b2ea0b3ef5caabe06592d9c51))

## [2.3.0](https://github.com/stevearc/conform.nvim/compare/v2.2.0...v2.3.0) (2023-09-06)


### Features

* format() takes an optional callback ([#21](https://github.com/stevearc/conform.nvim/issues/21)) ([3f34f2d](https://github.com/stevearc/conform.nvim/commit/3f34f2de48e393b2ee289f2c8fa613c7eabae6d8))


### Bug Fixes

* callback should always be called ([eb3ebb6](https://github.com/stevearc/conform.nvim/commit/eb3ebb6d2d114f6476a8f8d21d74f99c6d231a53))

## [2.2.0](https://github.com/stevearc/conform.nvim/compare/v2.1.0...v2.2.0) (2023-08-31)


### Features

* apply changes as text edits using LSP utils ([#18](https://github.com/stevearc/conform.nvim/issues/18)) ([92393f0](https://github.com/stevearc/conform.nvim/commit/92393f02efadfb1d9f97c74c8feb853c1caea9de))

## [2.1.0](https://github.com/stevearc/conform.nvim/compare/v2.0.0...v2.1.0) (2023-08-30)


### Features

* add golines ([#11](https://github.com/stevearc/conform.nvim/issues/11)) ([e1d68a5](https://github.com/stevearc/conform.nvim/commit/e1d68a58fa29d2a24f1a976c3c60521ffb31f32e))
* add perlimports ([#13](https://github.com/stevearc/conform.nvim/issues/13)) ([e6e99af](https://github.com/stevearc/conform.nvim/commit/e6e99af64db3f364086aaf55b8b5854ccd62bac4))
* add perltidy ([#12](https://github.com/stevearc/conform.nvim/issues/12)) ([882b759](https://github.com/stevearc/conform.nvim/commit/882b75994af34fed3c4fe6f1a97ad58b352ec25f))
* add shellharden ([#14](https://github.com/stevearc/conform.nvim/issues/14)) ([863fb46](https://github.com/stevearc/conform.nvim/commit/863fb46fc7a7fa66fafb4bb8fd8093c700c472e5))
* add support for environment variables ([#8](https://github.com/stevearc/conform.nvim/issues/8)) ([03a37f1](https://github.com/stevearc/conform.nvim/commit/03a37f1b53d83af7aee10fc3ffee9f3a05d09e2e))
* display last few lines of the log file in :ConformInfo ([c9327f2](https://github.com/stevearc/conform.nvim/commit/c9327f2af541e4a17a6e2e05682122f8c8455d29))
* formatter config function is passed the buffer number ([#9](https://github.com/stevearc/conform.nvim/issues/9)) ([8b2a574](https://github.com/stevearc/conform.nvim/commit/8b2a5741e07e2d6d5e8103e5e12356d3a9f0b8ba))
* notify when formatter errors, and add notify_on_error config option ([#16](https://github.com/stevearc/conform.nvim/issues/16)) ([08dc913](https://github.com/stevearc/conform.nvim/commit/08dc913fb22d402a98d1d9733536f2876c6f6314))


### Bug Fixes

* shellharden ([#15](https://github.com/stevearc/conform.nvim/issues/15)) ([288068b](https://github.com/stevearc/conform.nvim/commit/288068b1b78c79e64054ef443afbf6f2f5145da4))

## [2.0.0](https://github.com/stevearc/conform.nvim/compare/v1.1.0...v2.0.0) (2023-08-29)


### ⚠ BREAKING CHANGES

* remove ability for formatter list to disable autoformat

### Features

* can silence notification when running formatters ([#7](https://github.com/stevearc/conform.nvim/issues/7)) ([a4d793e](https://github.com/stevearc/conform.nvim/commit/a4d793e941e8e497ab9149ed09c946473d795c1b))
* ConformInfo command for debugging formatter status ([1fd547f](https://github.com/stevearc/conform.nvim/commit/1fd547fe98a5100a041106e2bc353363ab0d5ad8))
* range formatting ([cddd536](https://github.com/stevearc/conform.nvim/commit/cddd536e087a9fd3d2c9ea5b0a44e46c7b4b54c2))


### Bug Fixes

* don't show 'no formatters' warning if none configured ([9376d37](https://github.com/stevearc/conform.nvim/commit/9376d37bd7ab456b7df8e3d6f1ba75c05b4e5a8f))
* keep window position stable when LSP formatting ([90e8a8d](https://github.com/stevearc/conform.nvim/commit/90e8a8d63c7d77d1872dca3da720abfa07271054))
* remove unnecessary notify ([6082883](https://github.com/stevearc/conform.nvim/commit/6082883585a5c61c7a5c6697517931bc6e39f546))
* stable ordering when specifying multiple formatters ([69c4495](https://github.com/stevearc/conform.nvim/commit/69c4495ab5ad3c07c3a4f3c2bcac2f070718b4cb))


### Code Refactoring

* remove ability for formatter list to disable autoformat ([d508ae8](https://github.com/stevearc/conform.nvim/commit/d508ae8f46b5b41e2806b412311719a941167c1a))

## [1.1.0](https://github.com/stevearc/conform.nvim/compare/v1.0.0...v1.1.0) (2023-08-28)


### Features

* new formatter: fish_indent ([#5](https://github.com/stevearc/conform.nvim/issues/5)) ([446aa57](https://github.com/stevearc/conform.nvim/commit/446aa570048586f9c13f1ea88e280567f336691e))


### Bug Fixes

* gracefully handle another timeout case ([500d24d](https://github.com/stevearc/conform.nvim/commit/500d24dc1a2447a3c8f3f4f756f40bd27ff0b283))
* no need to save/restore window view ([5bc69d5](https://github.com/stevearc/conform.nvim/commit/5bc69d500a14fb06bf8f36005f76a7825be25931))

## 1.0.0 (2023-08-25)


### Features

* first working version ([eb5987e](https://github.com/stevearc/conform.nvim/commit/eb5987e9dd40ce1e27c9c07e41d09571f1bd876e))


### Bug Fixes

* don't modify files when no styling changes ([08b54ba](https://github.com/stevearc/conform.nvim/commit/08b54ba11e29e6df9f83c02539976331617a412c))
* ensure real buffer numbers get logged ([33ee8ba](https://github.com/stevearc/conform.nvim/commit/33ee8ba8cb6f29caec1edf01fa4987bbae52f18b))
* notification when no formatters available ([a757225](https://github.com/stevearc/conform.nvim/commit/a75722517d17d749a5ee86c8a3bbb098a61265fc))
* set a cwd for stylua ([a22781e](https://github.com/stevearc/conform.nvim/commit/a22781e0c3b609a5f90095f388589744567476c7))
