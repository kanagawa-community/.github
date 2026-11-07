# Preview images

Every port shows all three variants. Shell ports do it with one static image per
variant, rendered from a real session of the shell, so the colors in the picture
are the ones the theme produces and the three images stay comparable.

Ports for other applications take real screenshots instead. Follow the
[template](https://github.com/kanagawa-community/template) guidance and use
comparable content in each variant.

## Shell previews

Run the shell in a headless [tmux](https://github.com/tmux/tmux) pane with the
variant's theme applied, type the session below, capture the pane with
`tmux capture-pane -p -e`, and render the capture with
[termframe](https://github.com/pamburus/termframe) (MIT) to SVG, then convert it
to `assets/screenshots/<variant>.png` with `rsvg-convert`. Commit the script that does this, so a color
change is one command.

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

Give termframe a theme built from the variant's roles in
[palette.json](../palette.json):

- `ui.bg` as the background and `ui.fg` as the foreground.
- The `term.*` roles as the 16 terminal colors, so `eza` and the color row match
  the palette.

Do not use a stock termframe theme. Keep bold and underline: they are part of how
`eza` and the shell draw directories and paths. (freeze drops bold, so it is not
used here.)

### Render settings

Render with the shared
[termframe config](../config/termframe.toml), which sets the font, padding, line
height and the window: a macOS-style frame with a border and a shadow. Fetch it
by its raw URL, like `palette.json`, so a style change reaches every port:

```text
https://raw.githubusercontent.com/kanagawa-community/.github/main/config/termframe.toml
```

Pass only what changes per image:

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
