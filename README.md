# VGA Graphics on FPGA — Color Bars & Circles

SystemVerilog hardware that draws to a 160×120 framebuffer through a VGA adapter core. The design writes one pixel per 50 MHz clock with a small, restartable control interface and clean FSM/datapath structure.

---

## Table of Contents
- [Overview](#overview)
- [VGA Adapter (External IP)](#vga-adapter-external-ip)
- [Fill-Screen Renderer](#fill-screen-renderer)
- [Circle Renderer (Bresenham)](#circle-renderer-bresenham)
- [Verification and Validation](#verification-and-validation)
- [Results](#results)
- [Future Work](#future-work)

---

## Overview

The VGA core (produced by the University of Toronto) continuously scans a 160×120 framebuffer to drive a monitor. My logic writes pixels via `x`, `y`, `colour`, and a `plot` strobe; at most one pixel is written per cycle.

Key focuses:
- Deterministic, one-pixel-per-cycle plotting  
- Integer control for circle drawing  
- Simple, restartable start/done handshakes  

---

## VGA Adapter (External IP)

- **Inputs driven:** `x[7:0]`, `y[6:0]`, `colour[2:0]`, `plot`, `resetn`, `clock`  
- **Pixel write:** on the rising edge with `plot=1`, `(x,y)` is written to the framebuffer  
- **Color path:** adapter outputs 10-bit VGA RGB; on the DE1-SoC the 8 MSBs are routed to the DAC pins  

In simulation, vendor libraries are used; in post-synthesis simulation, Cyclone V device models are used. Testbenches observe only the adapter’s public inputs.

---

## Fill-Screen Renderer

### Purpose
Stream vertical color stripes across the entire display in minimum cycles (one pixel per cycle).

### Algorithm
    for x = 0..159:
        for y = 0..119:
            colour = x mod 8
            setPixel(x, y, colour)

### Implementation
- **FSM:** Two states, `READY` and `DRAW`.  
  - `READY`: resets coordinates, deasserts `plot`, clears `done`; transitions to `DRAW` when `start=1`.  
  - `DRAW`: asserts `plot=1` and streams pixels; returns to `READY` if `start=0`.  
- **Counters & control:**  
  - `vga_y` increments one step per cycle; a `first_iteration` flag prevents an extra increment on the first pixel after entering `DRAW`.  
  - A per-column flag (`donex`) signals when the column’s `y` range is complete, then `vga_x` increments and `vga_y` resets to `0` for the next column.  
- **Finish:** When the final column is complete, `plot` is lowered and `done` is asserted.  
- **Coloring:** `vga_colour` is wired to the module input; driving `x[2:0]` at the top level yields 8-color vertical stripes.

### Result
Streams one pixel per clock across all 160×120 positions and supports immediate reruns by deasserting `start`.

---

## Circle Renderer (Bresenham)

### Purpose
Draw a circle perimeter at an arbitrary center and radius using integer arithmetic, emitting one pixel per cycle and clipping off-screen coordinates.

### Algorithm
    offset_y = 0
    offset_x = radius
    crit = 1 - radius
    while offset_y ≤ offset_x:
        setPixel(cx + offset_x, cy + offset_y)   ; octant 1
        setPixel(cx + offset_y, cy + offset_x)   ; octant 2
        setPixel(cx - offset_x, cy + offset_y)   ; octant 4
        setPixel(cx - offset_y, cy + offset_x)   ; octant 3
        setPixel(cx - offset_x, cy - offset_y)   ; octant 5
        setPixel(cx - offset_y, cy - offset_x)   ; octant 6
        setPixel(cx + offset_x, cy - offset_y)   ; octant 8
        setPixel(cx + offset_y, cy - offset_x)   ; octant 7
        offset_y = offset_y + 1
        if crit ≤ 0:
            crit = crit + 2*offset_y + 1
        else:
            offset_x = offset_x - 1
            crit = crit + 2*(offset_y - offset_x) + 1

### Implementation
- **FSM:** `READY → PREP → OCT_1 … OCT_8 → CALC → (loop or DONE)`.  
  - `PREP` initializes `offset_y=0`, `offset_x=radius`, `crit=1-radius`.  
  - Each `OCT_*` state emits one pixel per cycle
  - `CALC` updates `offset_y`, `offset_x`, and `crit`. If `offset_y ≤ offset_x`, loops back to `OCT_1`; otherwise transitions to `DONE`.  
- **Datapath:** Signed registers store `offset_y` (8-bit), `offset_x`/`crit` (9-bit), and temporary signed pixel coordinates.  
- **Clipping:** Each octant state checks for negative coordinates before asserting `plot`.  
- **Coloring:** `vga_colour` is directly wired to the `colour` input.

### Result
Per-octant emission guarantees symmetry and deterministic one-pixel-per-cycle plotting. The state sequencing matches the Bresenham Algorithm, producing a pixel-accurate circle outline and avoiding off-screen writes.

---

## Verification and Validation

### Strategy
Combined directed RTL simulation, post-synthesis checks, and hardware inspection.

### Testbench Highlights
- **Fill-Screen (`tb_rtl_fillscreen`):**  
  - Verified reset initializes DUT in `READY`.  
  - Drove `start=1` and confirmed transition to `DRAW` and `vga_plot=1`.  
  - Checked that `vga_colour=4` when `colour=3'b100`.  
  - After ~192,000 cycles, confirmed `done=1` then cleared with `start=0`.  

- **Circle (`tb_rtl_circle`):**  
  - Verified state transitions `READY → PREP`.  
  - Checked `vga_colour=4`, correct `done` assertion after draw interval, and cleared outputs after `start=0`.  

### Waveform Checks
- Fill path: Continuous `plot` strobes, correct `vga_y` wrap and `vga_x` increment, `done` at final pixel.  
- Circle path: Observed octant sequence, `crit` updates, and loop termination when `offset_y > offset_x`.

### Post-Synthesis & Hardware
- Re-ran simulations with Cyclone V device libraries, confirmed pixel order and timing.  
- Deployed to DE1-SoC, visually confirmed color bars and circle outlines at expected positions and colors.

---

## Results

- Full-screen stripes render at one pixel per cycle with clean restart behavior  
- Circle outline follows Bresenham symmetry with per-octant emission and signed-math correctness  
- Simulation and hardware outputs align with expectations
