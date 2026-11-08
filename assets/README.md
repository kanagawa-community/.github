# Shared branding assets

Use this repository for branding and the palette swatches shared across Kanagawa
Community, such as the logo and other identity artwork.

Keep screenshots and runtime assets in their port repositories. Each port should
be able to document and use its theme without depending on files in another
repository.

The palette is the exception. [palette.json](../palette.json) defines the colors
of every variant, and the swatches in `palette/<variant>/<name>.svg` are generated
from it by [scripts/generate-palette.py](../scripts/generate-palette.py). Do not
edit the swatches by hand. See [PALETTE.md](../docs/PALETTE.md) for the roles and values.

Use absolute raw GitHub URLs when referencing shared assets from other
repositories:

```text
https://raw.githubusercontent.com/kanagawa-community/.github/main/assets/<path>
```

Keep published paths stable. Runtime assets belong in their port repositories.

## Branding files

- `branding/logo.png`: the community logo, 800x800 with transparent squircle
  corners. It keeps its path, so READMEs that link it pick up the new logo.
- `branding/avatar.jpg`: the same logo as a 1024x1024 square under 1 MB, for the
  organization avatar.

## Attribution and license

`branding/logo.png` is Hokusai's _The Great Wave off Kanagawa_ (public domain)
with the community title and the Wave palette colors. It replaces the logo that
was relocated from the community Neovim repository, derived from
[rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim).

The upstream repository distributes that earlier file and the palette color
values under its MIT license, copyright (c) 2021 Tommaso Laurenzi. The original
notice is preserved in [LICENSE](LICENSE). Relocation does not change authorship
or imply upstream endorsement.

The palette swatches reuse the circle artwork and color values from the same
upstream repository, under the same license and notice.
