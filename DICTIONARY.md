# Kanagawa dictionary

Use these terms consistently in READMEs, issues, repository descriptions, and
discussions across kanagawa-community.

## Identity

- **Kanagawa**: the theme family and visual identity inspired by Katsushika
  Hokusai's *The Great Wave off Kanagawa*.
- **kanagawa-community**: the independent community ecosystem and GitHub
  organization hosting its work.
- **Upstream**: the original project from which work derives. For the current
  Neovim port, this is [rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim).
- **Community-maintained**: maintained within this ecosystem. This does not imply
  upstream endorsement, official status, or succession. Do not describe a port as
  "official" without an explicit agreement.

## Themes and code

- **Variant**: Wave, Dragon, or Lotus. Capitalize display names; retain lowercase
  identifiers (`wave`, `dragon`, `lotus`) in code and configuration. Do not use
  "flavor" as a synonym.
- **Palette**: named colors and their values, not images of those colors.
- **Port**: a Kanagawa implementation for one application, such as Neovim.
  Introduce it as an "application theme" when readers may not know the term.
- **Integration**: support within a port for another component, such as the Neovim
  port's Telescope integration.
- **Repository**: a GitHub code or documentation container. A repository and a port
  are not synonyms.

## Presentation

- **Asset**: supporting media, such as an image, SVG, or font.
- **Documentation asset**: media used to explain or present a theme. Keep
  application-specific documentation assets with their port; store only
  organization-wide branding in the `.github` repository.
- **Runtime asset**: media needed for a theme to work. Keep it with its port.
- **Branding**: logos, banners, and shared identity artwork.
- **Screenshot**: an actual application capture.
- **Preview**: a presentation of a theme in documentation; it may contain multiple
  screenshots.
- **Swatch**: a visual sample of one palette color.

## People

- **Maintainer**: a person responsible for ongoing upkeep.
- **Contributor**: anyone who contributes work.

## Asset folder names

Use `assets/branding/` in `.github` for shared organization identity. Keep
application screenshots, swatches, and palette examples in the relevant port
repository.
