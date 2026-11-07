# Governance

Kanagawa Community is a community-maintained ecosystem. Each port depends on the
people who maintain it. This document describes how the organization makes
decisions, who holds which responsibilities, and how a port moves from proposal
to archive.

## Roles

- **Organization maintainers** have owner or maintainer access to
  `kanagawa-community`. They set org-wide direction, maintain this `.github`
  repository, approve new ports, add or remove maintainers, and handle conduct
  reports under the [Code of Conduct](CODE_OF_CONDUCT.md).
- **Port maintainers** are responsible for one port repository. They triage
  issues, review changes, publish releases, and keep the port aligned with the
  [dictionary](../docs/DICTIONARY.md) and the [template repository](https://github.com/kanagawa-community/template).
- **Contributors** are anyone who opens an issue, sends a pull request, or helps
  in discussion. Contributions are welcome in any form.

A person can hold more than one role. Port maintainers do not need to be
organization maintainers.

## Decisions

Organization maintainers decide by consensus. When consensus is not reached
within a reasonable time, the question is put to a vote among organization
maintainers, and a simple majority decides. Port maintainers decide the details
of their own port, within the shared guidance in this repository.

Changes to this document, the dictionary, the contributing guide, and shared
branding happen through a pull request to this repository.

## Port lifecycle

A port moves through these stages. Each stage is recorded on the proposal issue
or in the port repository.

1. Proposed. Someone opens a
   [port request](https://github.com/kanagawa-community/.github/issues/new?template=port-request.yml).
   The request names the application, its upstream source and license, and the
   planned maintainers. Every port must support all three variants.
2. Accepted. Organization maintainers confirm that the application fits the
   organization and that at least one maintainer has committed to the port. The
   proposal issue is closed as accepted.
3. Adopted. The port is built from the template repository, in the
   contributor's own account or by an organization maintainer in the
   organization, and reviewed. A repository from a contributor's account is
   transferred into `kanagawa-community`, then an organization maintainer
   completes the adoption checklist below. The port must support Wave, Dragon, and
   Lotus and credits the upstream project.
4. Maintained. The port publishes releases and responds to issues. Maintainers
   may ask for help in this repository when a change affects the shared guidance.
5. Archived. When maintenance stops, the maintainers say so in the port's
   README and an issue, then archive the repository. Archived ports keep their
   attribution and remain available for reference.

Organization maintainers may pause or archive a port that stops meeting these
requirements, after contacting its maintainers and allowing reasonable time to
respond.

### Adoption checklist

Organization maintainers complete this when a port is adopted. The
[adopt-port script](../scripts/adopt-port.sh) reports each item and, with
`--apply`, performs the ones marked automatic.

- The repository name is the application name in lowercase kebab-case, such as
  `windows-terminal`.
- The default branch is `main`. Automatic.
- The description reads "Community-maintained Kanagawa theme for Application".
  Automatic when the script gets `--app`.
- The topics include `kanagawa`, `theme`, and the repository name. Automatic.
- `README.md` follows the template, has no `{{placeholders}}` left, previews
  Wave, Dragon, and Lotus, and keeps screenshots under `assets/`.
- The template's placeholder preview images are replaced, both the showcase and
  the three variant images. The script flags any that are unchanged.
- The social preview is rendered with `scripts/render-previews.sh` (terminal
  ports) or `scripts/finish-previews.sh`, committed as
  `assets/social-preview.png`, and uploaded in the repository settings. Manual:
  the script reports whether an image is uploaded.
- The theme's colors come from the shared [palette](../docs/PALETTE.md) and follow the
  [style guide](../docs/STYLE-GUIDE.md), with no values sampled from screenshots.
- `LICENSE`, `cog.toml`, and the `commits.yml`, `files.yml`, and `assign.yml`
  workflows are present.
- The port does not carry its own copies of the organization's health files,
  such as the Code of Conduct. The ones in this repository apply.
- The shared ruleset and merge settings are applied. Automatic. See
  [rulesets](../rulesets/README.md).

Run `scripts/adopt-port.sh <repository>` for a dry run, then add `--apply`.

Apply it as early as possible: as soon as the template scaffold, with its
`commits.yml` and `files.yml` workflows, is on `main`. The ruleset needs only
those workflows, and the script reports the other items without blocking on
them. The port's content then arrives through pull requests that the ruleset
already protects. For a new repository in the organization, push the scaffold
commit to `main`, run the script with `--apply`, then open the content pull
request. Run it again once the content is merged to confirm the remaining items.

### Releases

Maintainers release a port with `scripts/release.sh` in this repository. The
script updates `CHANGELOG.md` and opens a pull request titled
`chore(release): <version>`. Merging that pull request tags the merge commit and
publishes the GitHub release, with the changelog section as its notes. A port's
first release is `1.0.0`: a port is complete when it is first released, and
later fixes cover what was missed. Later releases take the next version from the
conventional commits since the last tag. `--version` overrides either.

### Migrating existing extras

Application themes that currently live in the Neovim repository's `extras`
folder move to their own repositories, one per application. Each one goes
through the same lifecycle: a port request records it, maintainers are named,
and its README is brought in line with the template before the repository is
listed on the organization profile. The request may reuse the existing files as
its starting point, but the port repository becomes the only source for that
theme. Maintainers create these repositories in the organization themselves, so
they complete the adoption checklist as soon as each one exists.

## Attribution

Every port credits the project it derives from, and this organization credits
its own inspiration. Attribution is never removed to change the appearance of a
port. Relocating or adapting shared material keeps the original license notice,
as [assets/README.md](../assets/README.md) describes.

## Independence

kanagawa-community is independent of the original project and its maintainers.
Naming a port or a document after Kanagawa does not imply upstream endorsement
or succession.
