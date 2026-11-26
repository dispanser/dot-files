- Tmux with C-Space as prefix key: settings -> keyboard -> shortcuts -> input sources -> disable ^-space (and ^-shift-space)

- firefox / surfingkeys: `https://raw.githubusercontent.com/dispanser/dot-files/main/configs/surfingkeys/.config/surfingkeys.js`
- rustup component add rust-analyzer
- Tmux starts `default-shell` directly

## OmniWM

`ord` uses OmniWM 0.7.6 with IPC and the Niri layout.
`darwin.nix` imports `omniwm.nix`, which owns the launch agent and skhd shortcuts.
It declares two workspaces: `1` on the main display and `2` on the secondary display.
It disables OmniWM hotkeys, clipboard history, Hidden Bar, and the built-in quake terminal.
Skhd owns the bindings below.
**Mod** is the existing right-side modifier (`ralt`).
Previous-window switching and the remaining niri bindings are separate steps.

| Binding                   | Action                                                                                      |
| ---                       | ---                                                                                         |
| Mod-H / Mod-L             | Focus left / right within the focused layer.                                                |
| Mod-Ctrl-H / Mod-Ctrl-L   | Reorder tiled columns; move a focused float left / right by 5% of the screen width.         |
| Mod-Ctrl-J / Mod-Ctrl-K   | Reorder windows inside a column; move a focused float down / up by 5% of the screen height. |
| Mod-Ctrl-Shift-H/J/K/L    | Move a focused float so its edge aligns with the screen border; reorder a column to the first / last position (vertical: within the column). |
| Mod-,                     | Pull one window from the column on the right into the bottom of the focused tiled column.   |
| Mod-.                     | Split the bottom window into a new column on the right.                                     |
| Mod-W                     | Toggle the focused column between stacked and tabbed windows, matching niri.                |
| Mod-X                     | Open OmniWM's application launcher (matching Mod+X on NixOS).                               |
| Mod-Tab / Mod-Shift-Tab   | Focus the next / previous window within the current group, wrapping locally.                |
| Mod-J / Mod-K             | Focus down / up within the layer; continue to adjacent workspaces at vertical edges.        |
| Mod-1 / Mod-2             | Focus workspace 1 / 2, including its display.                                               |
| Mod-Shift-1 / Mod-Shift-2 | Send the focused window to workspace 1 / 2 and keep focus on the source workspace.          |
| Mod-S                     | Focus the next connected screen.                                                            |
| Mod-Shift-S               | Send the focused window to the next screen's visible workspace and follow it.               |
| Mod-`[` / Mod-`]`         | Move to the previous / next native macOS Space (reaches native-fullscreen apps).            |
| Mod-E                     | Type the work email address.                                                                |
| Mod-` (backtick)          | Type three backticks. Also on the ISO key left of Y (Mod-<>|).                              |
| Mod-Cmd-S                 | Sleep the machine immediately.                                                              |
| Mod-V                     | Toggle the focused window between floating and tiled.                                       |
| Mod-Shift-V               | Switch focus between floating and tiled windows.                                            |
| Mod-C                     | Center a tiled column or center the focused floating window.                                |
| Mod-F                     | Toggle full-width column maximization; leave floating windows unchanged, matching niri.     |
| Mod-Shift-H / Mod-Shift-L | Shrink / grow the focused float's width or the tiled column width by 10 percentage points.  |
| Mod-Shift-K / Mod-Shift-J | Shrink / grow the focused window's height by 10 percentage points.                          |
| Mod-- / Mod-=             | Same as Mod-Shift-H / L (alternative binding family).                                       |
| Mod-Shift-- / Mod-Shift-= | Same as Mod-Shift-K / J (alternative binding family).                                       |
| Mod-R                     | Cycle tiled-column or floating-window widths: 50%, 75%, 90%.                                |
| Mod-A                     | Focus T3 Code or cycle its windows.                                                         |
| Mod-M                     | Focus Slack or cycle its windows.                                                           |
| Mod-Z                     | Focus Zoom or cycle its windows.                                                            |
| Mod-Shift-M               | Focus Signal or cycle its windows.                                                          |
| Mod-B / Mod-;             | Focus Firefox or cycle its windows.                                                         |
| Mod-U                     | Focus Alacritty or cycle its non-parked windows.                                            |
| Mod-T                     | Focus or launch the main terminal (`code/main`).                                            |
| Mod-O                     | Show, focus, or hide the overlay terminal (`code/overlay`).                                 |
| Mod-Return                | Open Alacritty directly.                                                                    |

The workspace shortcuts use OmniWM's `switch-workspace anywhere` command.
This lets either display reach both configured workspaces.

### Workspace and screen movement

Numbered shortcuts select workspace IDs.
Workspace `1` is assigned to the main screen and workspace `2` to the secondary screen.
With one connected screen, both workspaces are available there.
Mod-Shift-1/2 sends one focused window and leaves you in the source workspace.
Use Mod-1/2 to visit the destination afterward.

Mod-S cycles connected screens in OmniWM's spatial order, including screens with empty workspaces.
With two screens, it switches to the other screen.
Mod-Shift-S sends one focused window to that screen's currently visible workspace, then follows it.
Both screen shortcuts do nothing when fewer than two screens are connected.

Sending works for tiled windows and ordinary floating windows.
The helper checks the actual foreground window and confirms the transfer before changing focus.
Exit fullscreen before sending a window.
Scratchpads retain their special membership; use Mod-O on the destination screen to summon the overlay.

### Application selection

Application shortcuts match macOS bundle IDs.
They focus the first matching window when another application is active.
Repeated triggers cycle matching windows in stable macOS window-ID order.
Parked scratchpad windows are excluded.
Navigation follows the target window's workspace without moving it.
Native scratchpads stay revealed when focus changes and can cover later tiled focus targets.
Before selecting another window or launching an app, the shortcut parks the owned overlay on the invocation workspace.
An explicit app-cycle selection of the overlay keeps it visible.
Other floating windows and scratchpad slots are unchanged.
Overlay dismissal and app activation share the terminal lock with Mod-O.
If parking fails or another terminal action holds the lock, the app switch is cancelled and reports an error.
If OmniWM has no matching window, macOS activates or launches the application.
IPC failures are reported without launching an application.
Mod-; aliases Firefox because qutebrowser is absent from this Mac.

### Column sizing and membership

Sizing shortcuts come in two equivalent families until the preferred binding settles: Mod-Shift with the direction keys (H/L width, K/J height), and the minus/equals keys (plain for width, Shift for height, matching niri).
Resize chords deliberately avoid the Alt modifier: skhd matches a chord containing `alt` on either alt key, which collided with typing special characters.
Holding Shift as well stretches that edge all the way to the screen border, or to full span when the edge is already there.
New columns default to 50% width.
OmniWM can expand underfilled tiled layouts to use available space.

Mod-, and Mod-. change column membership, matching the niri bindings in `configs/niri.kdl`.
They do nothing while a floating window or an unmanaged application has focus.
OmniWM handles column-edge and single-window cases without creating or closing windows.
These shortcuts do not change tmux panes or sessions.

### Tabbed columns

Focus Slack or Signal in their shared column and press Mod-W.
The active window uses the full column height.
A side strip shows each window's application icon, including inactive tabs.
Use Mod-Tab and Mod-Shift-Tab to switch to the next or previous window in the group.
These shortcuts wrap within the group without switching columns or workspaces.
They also work within a stacked column.
Click an icon to switch windows; hover to see the window title, application, and position in the group.
Press Mod-W again to restore the stacked view.

The icon strip is enabled through `appearance.tabRailAppIcons` in `omniwm-settings.nix`.
The setting must also be true in the installed `~/.config/omniwm/settings.toml`; rebuild and activate to install a repository change.
The toggle and group-cycling shortcuts affect only the focused tiled group.
They do nothing while a floating window or an unmanaged application has focus.
It does not group windows automatically or change their tmux sessions.

### Floating focus and sizing

The window-action helper selects the actual foreground application and window.
It prefers WindowServer IDs when one application owns several windows.
The IDs are matched through live Accessibility and WindowServer bounds.
This lets Cmd-N Alacritty windows change their titles without blocking layout shortcuts.
When no unique native ID is available, guarded title and frame matching remains the fallback.
Ambiguous matches leave the layout unchanged.
Before each tiled action, it synchronizes Niri's selected window with native keyboard focus.
The focused-window flag alone can disagree with the layout engine's selection.
It preserves native OmniWM commands for tiled focus.
For floating focus, directional keys consider only visible floats on the same workspace and display.
Selection uses the nearest window center along the requested axis, matching niri.
Horizontal focus does not wrap or switch to the tiled layer at an edge.
With only the overlay visible, Mod-H/L leaves it focused.
Mod-J/K continues to the adjacent configured workspace when there is no floating neighbor, matching the reference's window-or-workspace bindings.
It stays put when that display has no adjacent workspace.
Use Mod-Shift-V to switch back to tiled focus on the current workspace.

OmniWM 0.7.6 exposes column-sizing commands but no floating-frame action through IPC.
The helper uses public macOS Accessibility APIs to resize, move, and center a focused float.
It checks native focus again before changing geometry.
Width and height increments use the display's usable width and height.
macOS and applications can enforce minimum and maximum dimensions.
The resize increment and width presets come from `omniwm-settings.nix`.

Skhd needs Accessibility permission for these floating geometry actions.
When running the helper manually, its launching application needs that permission.
Missing permission, ambiguous window identity, and focus changes cause an error without changing the background tiled layout.
Screen Recording permission is unnecessary for these actions.

### Main and overlay terminals

These terminals use one fixed work context.
They require no project-named workspaces or changes to nuru.
Their tmux sessions are `code/main` and `code/overlay`.
Existing sessions are attached with `tmux new-session -A`; they are never killed or renamed.
New sessions start in `~/projects/coralogix`.
Only these terminal windows receive fixed titles; other Alacritty windows keep their normal title behavior.
The launcher uses the executable inside `Alacritty.app` so macOS exposes the bundle identity used by discovery and rules.

**Mod-T** reuses an existing Alacritty window titled exactly `code/main`.
If it is on another workspace, the helper brings it to the current workspace.
If it is missing, the helper creates a terminal client and attaches or creates the session.
Mod-T parks a revealed overlay on the invocation workspace before selecting the main terminal.
Pressing Mod-T while it is already focused leaves it focused.
Returning to the previous window is deferred.

**Mod-O** reserves native scratchpad slot **1**, labelled `overlay`.
A hidden overlay is revealed, a visible unfocused overlay is focused, and a focused overlay is hidden.
Application shortcuts such as Mod-M dismiss the revealed overlay before activating their target.
Mod-O brings back the same overlay window and tmux session.
New overlays start floating at 90 columns by 22 lines.
Their dimensions can be changed with the normal mouse resize controls.
The native scratchpad follows workspace switches while visible.
It can be summoned to another display by triggering Mod-O there.
OmniWM supports one revealed scratchpad slot at a time.

The helper refuses to overwrite scratchpad 1 if it contains another window.
It reconstructs the overlay's membership on the next Mod-O after an OmniWM restart.
It checks focus before assigning because OmniWM 0.7.6 can assign only the focused window through its CLI.
Overlapping terminal invocations are ignored to avoid duplicate launches.
Mod-T and Mod-O restore macOS-hidden terminals through OmniWM's explicit focus action.
A closed terminal window is recreated and reattaches its tmux session.
Exit fullscreen before toggling the overlay.

Startup output is written to `${XDG_CACHE_HOME:-~/.cache}/omniwm/terminal-main.log` or `terminal-overlay.log`.
The helper accepts only absolute XDG cache paths; other values use `~/.cache`.
Ambiguous window titles, IPC failures, and admission timeouts are reported without creating additional clients.

### Check and build

Run these commands from the repository root.
Builds leave the running configuration unchanged.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nixos-systems/nix-darwin/tests -v
nix build --no-write-lock-file ./nixos-systems/nix-darwin#darwinConfigurations.ord.system --out-link ./tmp/ord-system
```

### Activate when ready

Save work before activating the configuration.
Enable **Displays have separate Spaces** in macOS settings.
Use one native macOS Space per display for OmniWM workspaces.

```sh
sudo darwin-rebuild switch --flake ./nixos-systems/nix-darwin#ord
launchctl kickstart -k gui/$(id -u)/org.nixos.skhd
```

Home Manager installs OmniWM's launch agent.
Grant OmniWM **Accessibility** and **Input Monitoring** permission when requested.
Screen Recording is optional for tiling.
Keep OmniWM's own **Start at Login** disabled; Home Manager owns its launch agent.

Verify IPC after startup:

```sh
omniwmctl query capabilities
```

Use the bindings above, the workspace bar, or the CLI to navigate.
**Mod-Return** opens Alacritty directly.
Existing tmux sessions are unaffected by the window-manager configuration.

### Settings ownership

Edit `omniwm-settings.nix` and rebuild to keep settings declarative.
OmniWM requires a complete version 4 settings file, including tables for disabled features.
Recheck the schema when upgrading the package.
GUI edits can replace the managed settings symlink.
Home Manager restores the declared settings on the next switch, discarding those GUI edits.
