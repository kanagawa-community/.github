# Shared branding assets

Use this repository for branding shared across Kanagawa Community, such as the
logo and other identity artwork.

Keep screenshots, swatches, palette examples, and runtime assets in their port
repositories. Each port should be able to document and use its theme without
depending on files in another repository.

Use absolute raw GitHub URLs when referencing shared branding from other
repositories:

```text
https://raw.githubusercontent.com/kanagawa-community/.github/main/assets/<path>
```

Keep published paths stable. Runtime assets and executable palette definitions
belong in their port repositories.

## Attribution and license

The existing `branding/logo.png` was relocated without modification from
the community Neovim repository, derived from
[rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim).

The upstream repository distributes this file under its MIT license,
copyright (c) 2021 Tommaso Laurenzi. The original notice is preserved in
[LICENSE](LICENSE). Relocation does not change authorship or imply upstream
endorsement.
