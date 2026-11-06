# Kanagawa community home

This repository holds shared identity and guidance for
[kanagawa-community](https://github.com/kanagawa-community), an independent
community rooted in the original
[Kanagawa colorscheme](https://github.com/rebelot/kanagawa.nvim).

- [Organization profile](profile/README.md)
- [Governance](.github/GOVERNANCE.md) - roles, decisions, and the port lifecycle
- [Dictionary](DICTIONARY.md) - shared terminology for documentation and discussions
- [Brand asset guidance and attribution](assets/README.md)
- [Template repository](https://github.com/kanagawa-community/template) - starting point for a new port: README, license, cocogitto config, and workflows
- [Contributing](.github/CONTRIBUTING.md) - guidance for port and shared-repository contributions, including how to propose a port
- [Issue forms](.github/ISSUE_TEMPLATE/) - port request and bug report forms used by default across the organization
- [Rulesets](rulesets/README.md) - branch protection, signed commits, and conventional commit checks, with the script that applies them
- [Shared tool configuration](config/) - markdownlint and yamllint settings used by the file checks
- [Adopt-port script](scripts/adopt-port.sh) - checks a port against the adoption checklist and finishes its setup
- [Support](.github/SUPPORT.md) - where to ask for help or report an issue
- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Security policy](.github/SECURITY.md) - private vulnerability reporting

## Attribution

The organization's layout, with a shared `.github` repository for profile,
governance, and community health files, is inspired by
[Catppuccin](https://github.com/catppuccin). The wording and files here are
Kanagawa's own.

## License

This repository is licensed under the [MIT License](LICENSE), covering its
documentation, workflows, scripts, and configuration. Two parts differ:

- The [Code of Conduct](.github/CODE_OF_CONDUCT.md) is adapted from the Contributor
  Covenant and stays under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
- The logo in `assets/branding/` keeps the upstream MIT notice described in
  [assets/README.md](assets/README.md).

## Repository boundaries

Application theme code, screenshots, swatches, and palette examples belong in
their port repositories. Only branding shared across the organization belongs
here. Runtime assets must remain with the port that needs them; using a theme
must not require downloading documentation assets.

When moving an asset, publish it here before adding README links that use it.
Keep published paths stable because other repositories reference them by URL.
