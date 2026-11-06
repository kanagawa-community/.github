# Contributing

Contributions to Kanagawa ports and shared organization resources are welcome.
Read the relevant repository's README and contribution guide first. Each port's
maintainers decide its installation, code, and release details.

## Application themes

- Open port-specific fixes and documentation changes in the relevant port
  repository.
- Every port must support Wave, Dragon, and Lotus.
- Start from the [template repository](https://github.com/kanagawa-community/template). Keep screenshots
  and runtime assets in the port repository.
- Take colors from the shared [palette](../PALETTE.md) and follow the
  [style guide](../STYLE-GUIDE.md) instead of sampling or guessing them.
- Attribute a source project when the implementation is based on one. Do not
  imply upstream endorsement or official status.

## Proposing a port

1. Open a [port request](https://github.com/kanagawa-community/.github/issues/new?template=port-request.yml).
   The form asks for the application, its upstream source and license, and the
   planned maintainers.
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

Use the [dictionary](../DICTIONARY.md) terms in issues, pull requests, and
documentation.

## Checks and tests

Every pull request runs these checks, and all of them must pass before it can
be merged:

- `conventional-commits / check` verifies commit messages with
  [cocogitto](https://docs.cocogitto.io/).
- `files / format` checks formatting with [Prettier](https://prettier.io/) for
  Markdown, JSON, and YAML, and with [taplo](https://taplo.tamasfe.dev/) for
  TOML.
- `files / lint` runs [markdownlint](https://github.com/DavidAnson/markdownlint-cli2),
  [yamllint](https://github.com/adrienverge/yamllint), and
  [actionlint](https://github.com/rhysd/actionlint).

Fix formatting before you push with `npx prettier --write` on the files you
changed and `npx @taplo/cli fmt` for TOML. The tool versions are pinned in
[`check-files.yml`](workflows/check-files.yml).

A port can keep its own configuration for any of these tools. A configuration
file in the port, such as `.prettierrc.json`, `.markdownlint-cli2.jsonc`, or
`.yamllint`, takes precedence over the shared one in [config/](../config/). Use
the tools' ignore files for generated files.

A port can add its own tests as separate workflows. To make a test required,
ask an organization maintainer to add a ruleset that requires its check.
Rulesets add up, so this leaves the shared one unchanged.

## Testing workflows locally

Before you open a pull request that changes a workflow, you can run it on your
machine with [act](https://github.com/nektos/act). It needs Docker or Podman.

```sh
# Run the file checks
act pull_request -W .github/workflows/files.yml

# Run one job, or print what would run without running it
act pull_request -W .github/workflows/files.yml -j format
act pull_request -W .github/workflows/files.yml -n
```

- The `.actrc` file in the repository picks a runner image that includes Node
  and common tools. The first run downloads it.
- With Podman, point act at the Podman socket by setting `DOCKER_HOST` to
  `unix://$XDG_RUNTIME_DIR/podman/podman.sock`.
- The commit check reads the pull request's base and head commits, so give it an
  event file with `-e event.json`:

  ```json
  {
    "pull_request": {
      "base": { "sha": "the commit your branch started from" },
      "head": { "sha": "your latest commit" }
    }
  }
  ```

- Do not give act a real `GITHUB_TOKEN` for the release or assign workflows.
  They push tags, create releases, and edit pull requests, so leave them to
  GitHub.

Act does not cover rulesets, required checks, merging, commit signing, or the
exact behavior of `pull_request_target`. Check those on GitHub.

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
  and direct pushes to the default branch are blocked. See [rulesets](../rulesets/README.md).
- Use the repository's `.editorconfig` so indentation and line endings match.

Contributions must be your own work or content you have permission to share.
Follow the license and any contribution instructions in the repository receiving
your change. Contributions to this repository are licensed under the
[MIT License](../LICENSE).
