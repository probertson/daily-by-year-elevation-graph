# daily-by-year-elevation-graph
Generate a 3d model of data in a grid (great for "daily data for a year")

This script (`daily-by-year-elevation-graph.scad`) generates a 3d model
consisting of a grid of cells (X and Y axes) The elevation (Z axis) of
each cell is defined by a value in an array of data.

## How to use:

1. Save a copy of the file `data-by-year__example.scad` with the name `data-by-year.scad`. This file
   will be ignored by git. It is where you can put the data for your chart. (Alternatively
   you can name the file whatever you want and just change the `include` statement in the code.)

2. Open the file `daily-by-year-elevation-graph.scad` using [OpenSCAD](https://openscad.org/).

3. Run the script to see a chart. By default the data is organized into a grid (from the top-down
   view) somewhat like a GitHub contribution graph. Each "column" (y-axis) is a week, with days running down
   from Sunday to Saturday.

   ![Example graph rendered in OpenSCAD](assets/daily-by-year-elevation-graph-example.png?raw=true "Example graph rendered in OpenSCAD")
   
   However, the code doesn't require a fixed number of values or specific grid dimensions. It could
   be used to show days in a month or even values where the x- and y-axis don't represent time at all.

4. You can change the data in `data-by-year.scad`. The format is documented there. You can
   also configure several parameters in `daily-by-year-elevation-graph.scad`, to change
   (among other things) the dimensions of the grid, the scale, etc.

Note that this code was developed using OpenSCAD version 2018.10.13.ci145, and it
uses some apis that are not available in earlier versions.

## Background

This could be used to make a 3d bar chart of any type of data. However, it was
originally written to create a 3d graph of "daily by year" data -- that is,
data containing one value per day, where an entire chart represents a year.

My employer, HireVue, Inc., provides an online job interview platform. The
first version of this was created as a "hack week" project to create 3d-printed
models of the daily number of interviews, broken out by year.

## Credits/Acknowledgements

As mentioned above, the first implementation of this code was written as part of my employment with
with HireVue, Inc. ([@hirevue](https://github.com/hirevue)). Thanks to them for giving me permission to release this work
as open source. It's a great place to work -- check us out!
