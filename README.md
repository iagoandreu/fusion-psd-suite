# Patient-specific device tools for Fusion

A set of Autodesk Fusion add-ins for designing patient-specific devices - surgical
guides, plates, implants and their screw trajectories - from a CT segmentation,
inside Fusion. Each tool does one step that Fusion has no command for, and reports
how far its result is from its input so you can check it rather than trust it.

They were written in a hospital 3D-printing lab and are shared so other residents
can use them, fix them and add to them. Every tool is its own repository; this one
lists them, installs them together, and explains where each fits.

## The tools

| Step | Tool | What it does | External Python |
|---|---|---|---|
| Bring the anatomy in | [Mesh to Part](https://github.com/iagoandreu/mesh-to-part) | Turns a segmented STL into a solid or a smooth T-spline Form body under a measured maximum error; **Wrap** grows or shrinks a body by a distance where Offset Face and Shell give up on organic shapes. | yes |
| Put it in place | [Global Registration](https://github.com/iagoandreu/global-registration) | Aligns one body onto another by shape alone, no landmarks (e.g. a mirrored healthy side onto the affected one, a plan onto a new scan), and carries other bodies along. | yes |
| | [Align Planes](https://github.com/iagoandreu/align-planes) | Brings a moving plane onto a fixed one (a cutting slot onto a planned osteotomy, a plate face onto a resection) and carries bodies along. | no |
| Outline on the bone | [Bone Guide](https://github.com/iagoandreu/bone-guide) - **Bone Curve** | A closed curve on the bone, from the drill cylinders or a sketch, edited like a spline whose points slide over the bone. | yes |
| | [Intersection Sketch](https://github.com/iagoandreu/intersection-sketch) | The contour where two bodies meet, as an editable fitted spline. | no |
| | [Alpha Shape](https://github.com/iagoandreu/alpha-shape) | A lofted solid envelope round several bodies (pins, screws, drill sleeves), gaps closed with round arcs. | yes |
| Grow the device | [Bone Guide](https://github.com/iagoandreu/bone-guide) - **Guide Base** | The guide base inside the curve: thickness and wall along the bone normal, rounded rim, drill tubes. | yes |
| | [Outline Patch](https://github.com/iagoandreu/outline-patch) | Cuts the bone surface inside a closed 3D outline exactly and thickens it into a new body, with an optional rounded rim. | yes |
| Screw and pin trajectories | [Axis Cylinder](https://github.com/iagoandreu/axis-cylinder) | A cylinder along a direction read off the model - a fitted plane normal, an edge or axis, a cylindrical face, a cylinder fitted to a scanned surface - placed where it is on screen. | no |
| | [Fit Primitives](https://github.com/iagoandreu/fit-primitives) | Paint a region of a surface with a brush and fit a cylinder or a plane to it, with the deviation reported. | no |
| Porous regions | [Lattice](https://github.com/iagoandreu/voronoi-lattice) | Fills a volume with a Voronoi foam or a regular cell (cubic, BCC, FCC, octet, diamond, Kelvin), or covers a surface with a Voronoi or cubic net, as a Form or a mesh, with the porosity measured on what was built. | yes |
| Out to the printer | [Batch STL Export](https://github.com/iagoandreu/batch-stl-export) | Exports many bodies or components to STL in one pass, with refinement settings remembered between runs. | no |

**Every tool's README starts with a *How to use* section**: where the button is,
what to select, every option in the dialog, what gets built, and what to check
before you trust it. Read it before the first use.

## A typical case

1. Segment the CT in your segmentation software and export the bone (and the
   contralateral side, if you plan by mirroring) as STL.
2. Import it in Fusion (*Insert > Insert Mesh*). **Mesh to Part** turns it into a
   body you can design against, within an error you choose.
3. **Global Registration** puts the mirrored healthy side, or last month's plan, onto
   the bone. **Align Planes** sets a cutting slot or a plate face on a planned plane.
4. Draw where the guide touches the bone: **Bone Curve**, **Intersection Sketch**
   (where two bodies meet) or **Alpha Shape** (an envelope round the drills).
5. Grow the guide: **Guide Base** or **Outline Patch**.
6. Add the trajectories: **Axis Cylinder** for screws and pins, **Fit Primitives**
   when the direction comes from a scanned surface. Subtract them for holes.
7. **Lattice** for porous or lightweight regions.
8. **Batch STL Export** for printing.

## Installing

You need Fusion on Windows. Then:

1. Download this repository (*Code > Download ZIP*, or `git clone`).
2. In that folder, run in PowerShell:

   ```powershell
   powershell -ExecutionPolicy Bypass -File install_all.ps1
   ```

   It downloads every tool (with git if you have it, as a zip if you do not) into
   `Documents\fusion-psd-suite-tools`, installs each one into Fusion's add-in folder,
   and checks the Python below. Run it again to update. To install only some:
   `install_all.ps1 -Only axis-cylinder,bone-guide`.
3. Restart Fusion. The tools start on their own; *Utilities > Add-Ins* lists them.

**External Python.** Fusion's own Python has no numpy, so the tools marked *yes*
above run their maths in a separate Python. Install
[Python 3.10](https://www.python.org/downloads/) (64-bit), then:

```powershell
py -3.10 -m pip install -r requirements.txt
```

Each tool finds it through `py -3.10`, the usual install folders, or a
`python_path.txt` beside the installed add-in naming the interpreter to use - its
README says exactly which.

A single tool can also be installed on its own: download its repository and run its
`install.ps1`.

## Before you use a result clinically

These are design aids. They are not medical device software, they are not validated,
and they come with no warranty (MIT licence).

The device you make with them is your institution's responsibility: a custom-made
device under MDR (EU) 2017/745 Annex XIII, or an in-house device under Article 5(5).
If your quality system uses them in design or production, ISO 13485:2016 asks you to
validate software for its intended use before first use, proportionately to the
risk, and again after changes (4.1.6, 7.5.6). Every tool reports measured deviations
to support that; check them on every case, and check the final geometry yourself in
Fusion before it goes to print.

Never commit patient data to any of these repositories - not a mesh, a case number
or a name, not even in an issue.

## Contributing

Fixes, new options and new tools are welcome. [CONTRIBUTING.md](CONTRIBUTING.md) has
the layout every tool follows and the rules that keep them trustworthy.

## Licence

MIT - see [LICENSE](LICENSE). Each tool carries its own MIT licence.
