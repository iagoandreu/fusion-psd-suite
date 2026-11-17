# Adding to the suite

Every tool is its own repository and its own Fusion add-in, so one can be fixed,
installed or dropped without touching the others. This repository only lists them
(`tools.json`), installs them (`install_all.ps1`) and explains how they fit together.

## Fixing or improving a tool

1. Open an issue on that tool's repository saying what went wrong, with the Fusion
   version, what you selected, and the log file (`<Tool>.log` in the installed add-in
   folder, `%APPDATA%\Autodesk\Autodesk Fusion 360\API\AddIns\<Tool>\`).
2. Fork it, change it, run its tests (see below), open a pull request.

Never attach a patient's mesh, a CT export or anything carrying a case number or a
name, not even to an issue. Reproduce the problem on a primitive (a box, a cylinder,
a sphere) or a public anatomical model.

## Adding a tool

Make a new repository from the layout every tool here already uses:

| File | Role |
|---|---|
| `<Tool>.py` | the shell: command registration and lifecycle only. Fusion keeps it loaded, so changing it needs the add-in stopped and run again. Keep it boring. |
| `<xx>_core.py` | all the working code, re-imported on every command event - edit it and the next click runs the new code. No state in module globals between events. |
| `<xx>_engine.py` | maths that needs numpy/scipy. Fusion's own Python has neither, so it runs in an external Python 3.10+ as a subprocess, found through an environment variable, then `python_path.txt` beside the add-in, then `py -3.10`. |
| `<Tool>.manifest` | `"type": "addin"`, `"runOnStartup": true` |
| `install.ps1` | copies the add-in into Fusion's AddIns folder. List every file the add-in needs. |
| `tests/` | offline tests that run with `py -3.10`, against a stub of the Fusion API where they need one |
| `resources/` | 16, 32 and 64 px icons |
| `README.md` | with a **How to use** section a resident can follow without reading code |
| `LICENSE` | MIT |

Then add it to `tools.json` and to the table in this repository's README, and open a
pull request here.

## Rules that keep the tools trustworthy

- **Report what was measured.** A tool that fits, offsets or converts geometry says
  how far the result is from its input (rms and worst deviation) in the dialog or the
  log. Users should never have to take a result on trust.
- **Test in a scratch document.** A self-test opens a new document and closes it
  unsaved. Never in someone's open design: undoing a parametric BaseFeature by code
  fails silently.
- **Centimetres inside, millimetres outside.** The Fusion API works in cm; everything
  a user sees is mm. Convert in exactly one place.
- **Read what Fusion actually returns.** Several API calls do not behave as documented
  (several READMEs list the ones their authors ran into). Verify a call in the live app before
  relying on it, and write down what you found.
- **The optional dev bridge stays off.** Tools may watch a job folder for automated
  testing, but only when a `devbridge.on` file exists beside the installed add-in.
  Never commit that file.
- **Neutral names.** Name a tool and its presets by what they do, not after a company,
  a product or a paper.
- **No patient data in a repository**, in any file, test, comment or commit message.
