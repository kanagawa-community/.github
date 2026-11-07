# Preview images

Every port shows all three variants. Shell ports do it with one static image per
variant, rendered from a real session of the shell, so the colors in the picture
are the ones the theme produces and the three images stay comparable.

Ports for other applications take real screenshots instead. Follow the
[template](https://github.com/kanagawa-community/template) guidance and use
comparable content in each variant.

## Rendering terminal previews

Terminal ports, shells and other command-line tools, render their images with
[scripts/render-previews.sh](../scripts/render-previews.sh). Run it from the port's
directory. It needs no checkout of this repository, and fetches what it needs:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/kanagawa-community/.github/main/scripts/render-previews.sh)
```

With a checkout next to the port, `scripts/render-previews.sh ../fish` does the
same from here.

The port commits only `scripts/preview.sh`, which the script sources. It sets
`name` (the application name as it should read) and a `capture` function that
writes the colored output of one variant to a file. Optional `setup` and
`cleanup` functions run once before the first capture and on exit. Everything
after the capture is shared: [termframe](https://github.com/pamburus/termframe)
(MIT) renders each capture to SVG with the settings below, `rsvg-convert` turns it
into `assets/screenshots/<variant>.png`, and the showcase and social preview are
built from the three images. Do not copy any of this into a port. See
[fish](https://github.com/kanagawa-community/fish/blob/main/scripts/preview.sh)
and [delta](https://github.com/kanagawa-community/delta/blob/main/scripts/preview.sh)
for examples.

## Shell previews

A shell's `capture` runs the shell in a headless [tmux](https://github.com/tmux/tmux)
pane with the variant's theme applied, types the session below, and captures the
pane with `tmux capture-pane -p -e`.

### The session

Every shell port runs the same commands in the port's own directory. Some steps
depend on what the shell can do, so each is marked.

| #   | Command                                                | Applies to                         | What it shows                                     |
| --- | ------------------------------------------------------ | ---------------------------------- | ------------------------------------------------- |
| 1   | `fastfetch -l none -s colors`                          | all shells                         | The 16 terminal colors                            |
| 2   | the syntax line below                                  | shells that highlight while typing | Syntax colors on real input                       |
| 3   | `eza -alF --icons --group-directories-first --no-user` | all shells                         | `LS_COLORS` and ANSI colors on real files         |
| 4   | `nosuchcommand --flag`                                 | shells that highlight while typing | The error color and the shell's own error message |
| 5   | `fastfetch` and a space, typed and not run             | shells with autosuggestions        | The autosuggestion color                          |

A shell without live highlighting, such as bash, shows only steps 1 and 3 and its
prompt. Do not fake highlighting the port does not provide. A shell with a theme
preview command of its own may add it after step 2, but it is optional.

The syntax line, for bash, zsh and fish 3.4 or later:

```sh
echo "Hi, $USER" 'from' $(basename $PWD) | tr A-Z a-z && ls *.md > /dev/null || echo no # comment
```

It runs harmlessly and prints `hi, kanagawa from fish`. It shows a command, an
option, a double-quoted and a single-quoted string, variables, command
substitution, a pipe, a glob, a redirection to a real path, `&&` and `||`, and a
comment. Shells that cannot run it, such as Nushell and PowerShell, use the
closest equivalent that shows the same things. Keywords such as `if` and `for`
differ too much between shells to share a line, so a port may add one.

Run every command with the environment `USER=kanagawa` (set it in the shell if it
ignores the environment, as fish does), so the account name of whoever renders
the images stays out of them.

Use the same prompt in every port: user `kanagawa`, the variant (`wave`, `dragon`
or `lotus`) as the host, the full path with no shortening, then a newline and
`❯`. Take the prompt colors from the theme, not from hard-coded values.

### Colors

termframe gets a theme built from the variant's roles in
[palette.json](../palette.json) by
[scripts/termframe-theme.py](../scripts/termframe-theme.py):

- `ui.bg` as the background and `ui.fg` as the foreground.
- The `term.*` roles as the 16 terminal colors, so `eza` and the color row match
  the palette.

Do not use a stock termframe theme. Keep bold and underline: they are part of how
`eza` and the shell draw directories and paths. (freeze drops bold, so it is not
used here.)

### Render settings

Rendering uses the shared
[termframe config](../config/termframe.toml), which sets the font, padding, line
height and the window: a macOS-style frame with a border and a shadow. The config
has no `[[fonts]]` entry, because font files live in different places on every
machine, so the render script adds one for the installed font with `fc-match`.
Without it termframe measures generic metrics and the glyphs drift apart.

Only what changes per image is passed:

| Setting        | Value                                  |
| -------------- | -------------------------------------- |
| `--theme`      | the variant's theme, `--mode` to match |
| `--title`      | the port name, such as `fish`          |
| `--width`      | the widest line of the capture         |
| `--height`     | the lines of the capture, plus one     |
| `--output`     | an SVG file                            |
| `rsvg-convert` | `--zoom 2`, to `<variant>.png`         |

Set `LC_ALL=C` and a fixed home directory so the listing looks the same on every
machine. The listing changes only when the port's files or their sizes do.

A static render cannot show interactive features such as autosuggestions or
completion menus. Mention them in the README instead of faking them.

### Showcase image

Stack the three renders into one image, `assets/showcase.png`, with
[scripts/compose-showcase.sh](../scripts/compose-showcase.sh). Lotus is at the
back, Dragon in the middle and Wave in front. Each window sits a fifth of its
width to the right and a quarter of its height below the one behind it, on a
transparent background:

```sh
compose-showcase.sh assets/screenshots/lotus.png assets/screenshots/dragon.png \
  assets/screenshots/wave.png assets/showcase.png
```

The script needs ImageMagick, and the three images must be the same size. Show the
result at the top of the README's Previews section, above the three images in
their collapsible sections. Keep the three images in `assets/screenshots/`.

## Social preview

Ports do not run the two steps above by hand. `scripts/finish-previews.sh <name> <port-dir>`
builds `assets/showcase.png` and `assets/social-preview.png` from the three images in
`assets/screenshots/`. `render-previews.sh` ends by calling it. Ports with real
screenshots run it themselves after replacing the three images.

GitHub shows a repository's social preview when its link is shared. Every port
uses the same one: the logo, "Kanagawa for <name>", the variant names, and the
showcase image, on the Wave background. Render it from the `.github` repository:

```sh
scripts/social-preview.sh fish ../fish/assets/showcase.png ../fish/assets/social-preview.png
```

The script takes the name as it should read (`fish`, `Neovim`, `Windows Terminal`),
the port's showcase image, and the output file. It produces a 1280x640 PNG, which is
GitHub's recommended size and well under its 1 MB limit, and it needs `rsvg-convert`,
ImageMagick, and Python. Commit the result as `assets/social-preview.png`, then
upload it by hand under Settings > General > Social preview in the port's
repository.
