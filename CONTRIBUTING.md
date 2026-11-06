# Contributing

Contributions to Kanagawa ports and shared organization resources are welcome.
Read the relevant repository's README and contribution guide first. Each port's
maintainers decide its installation, code, and release details.

## Application themes

- Open port-specific fixes and documentation changes in the relevant port
  repository.
- New and maintained ports are expected to support Wave, Dragon, and Lotus.
- Start from the [template repository](https://github.com/kanagawa-community/template). Keep screenshots,
  swatches, palette examples, and runtime assets in the port repository.
- Attribute a source project when the implementation is based on one. Do not
  imply upstream endorsement or official status.

## Proposing a port

1. Open a [port request](https://github.com/kanagawa-community/.github/issues/new?template=port-request.yml).
   The form asks for the application, its upstream source and license, the
   variants, and the planned maintainers.
2. Organization maintainers review the request against the
   [governance](GOVERNANCE.md) lifecycle: proposed, accepted, adopted.
3. Build the port from the
   [template repository](https://github.com/kanagawa-community/template) in your
   own account, and link it in the request when it is ready for review.
4. After review, an organization maintainer asks you to transfer the repository
   into the organization and completes the adoption checklist in the
   [governance](GOVERNANCE.md) guide. You are welcome to stay on as a
   maintainer.

## Shared organization resources

Use this repository for identity, guidance, and resources shared across ports.
Open an issue here to propose changes to shared documentation or branding, or
open a pull request with the change when you have it ready.

Use the [dictionary](DICTIONARY.md) terms in issues, pull requests, and
documentation.

## Commits, branches, and formatting

- Name branches `<type>/<short-description>`, where the type is a commit type
  such as `feat`, `fix`, `docs`, `ci`, or `chore`. Use lowercase words separated
  by hyphens, for example `docs/clarify-port-lifecycle`.
- Write every commit message with
  [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), such
  as `docs: clarify port lifecycle`. A check on every pull request enforces
  this, because [cocogitto](https://docs.cocogitto.io/) derives each release
  version from the commit types. Older history in some ports predates the rule.
- Sign your commits. The default branch rejects unsigned commits. GitHub's guide to
  [signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
  explains how to set it up.
- Pull requests are merged with a merge commit, which keeps your signed commits,
  and direct pushes to the default branch are blocked. See [rulesets](rulesets/README.md).
- Use the repository's `.editorconfig` so indentation and line endings match.

Contributions must be your own work or content you have permission to share.
Follow the license and any contribution instructions in the repository receiving
your change. Contributions to this repository are licensed under the
[MIT License](LICENSE).
