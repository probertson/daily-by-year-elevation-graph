// Data for a year by day
// Using a 3d elevation/bar chart

// Whether to add a separation line between walls.
// `false` makes the sides solid faces, so weeks aren't distinct from the side.
tower_gaps = true;

// Whether to round the data up to the nearest 10.
// `true` means the data isn't as distinct, but helps maintain some difference in the data if the data
// is all small enough that it's only a few layers high.
round_data = false;

// Whether to add embossed text to the bottom of the base. Set the actual text below in `base_label`.
add_text = true;

// Font size in mm for the label ("Cap" height, i.e. the distance between the baseline and the top of uppercase letters)
// Set to 0 for "auto-fit" -- in that case letters are sized so they fit in the model vertically with one "block" padding
// on the top and bottom.
font_size = 0;

// This pulls in the file containing the actual data. To add your own data, put it in "data-by-year.scad"
// or else change the name of the file to point to the file with your data.
// The format is to use one OpenSCAD vector (`year_data` in this example) to represent data for one year:
// year_data[0] is the day number of the first day of the year (January 1)
//   0 = Sunday, 1 = Monday, 2 = Tuesday, ..., 6 = Saturday
// year_data[1] is a vector containing all the values by day for the year
//   [ <day 1 value>, <day 2 value>, ..., <day 365/366 value>]
// Example:
// data_2014 = [
//   3,
//   [1, 4, 1, 5, 9, ..., 3]
// ];

include <data-by-year.scad>;

// Change this to set the name of the actual data set you want to use. The value is the name of the vector.
year_data = temp_2018;

// This is the text that is printed into the bottom of the model (if `add_text` is `true` above).
base_label = "TEMP 2018";

// x and y dimension of each day
day_width = 2.5;

// z height per unit value
scale_z = 1;

// minimum layer thickness of the printer
// This ensures that values that would be too small to be printed still appear,
// albeit rounded up to the value equal to one layer.
min_layer_height = .05;

// number of days in y axis before wrapping
days_per_column = 7;

// how thick is the base
baseplate_thickness = 4;

// How far below the top of a tower to add a separation between walls
// .5 makes a distinct separation. 0 makes the columns blend together more, which might be desirable depending on
// what the data represents.
min_visible_depth = .5;


// You (probably) don't need to change anything below this line
//
first_day_of_year = year_data[0];
data = year_data[1];

padding = first_day_of_year > 0 ? [ for (i = [1 : first_day_of_year]) -1 ] : [];
padded_data = concat(padding, data);

max_x = day_width * (len(padded_data) - 1) / days_per_column;
max_y = day_width * (days_per_column - 1);

function column_number(cell_number) = floor(cell_number / days_per_column);

function row_number(cell_number) = cell_number % days_per_column;

function cell_x(cell_number) = column_number(cell_number) * day_width;

function cell_y(cell_number) = max_y - (row_number(cell_number) * day_width);

function quicksort_segments(arr) = !(len(arr) > 0) ? [] : let(
    pivot   = arr[floor(len(arr) / 2)][1],
    lesser  = [ for (y = arr) if (y[1]  < pivot) y ],
    equal   = [ for (y = arr) if (y[1] == pivot) y ],
    greater = [ for (y = arr) if (y[1]  > pivot) y ]
) concat(
    quicksort_segments(lesser), equal, quicksort_segments(greater)
);

module rounded_cube(size, roundness, height) {
  inner_size = size - (2 * roundness);
  for (x = [0, 2]) {
    for (y = [0, 2]) {
      x_offset = (x * inner_size / 2) + roundness;
      y_offset = (y * inner_size / 2) + roundness;
      translate([x_offset, y_offset, 0]) {
        cylinder(r = roundness, h = height, center = false, $fn = 20);
      }
    }
  }
  translate([roundness, 0, 0]) cube([inner_size, size, height], center = false);
  translate([0, roundness, 0]) cube([size, inner_size, height], center = false);
}

CORNER_SW = 0;
CORNER_NW = 1;
CORNER_SE = 2;
CORNER_NE = 3;
module rounded_corner_cube(size, anchor_corner, roundness, height) {
  cyl_x = (anchor_corner == CORNER_SW || anchor_corner == CORNER_NW) ? roundness : size - roundness;
  cyl_y = (anchor_corner == CORNER_SW || anchor_corner == CORNER_SE) ? roundness : size - roundness;
  translate([cyl_x, cyl_y, 0]) {
    cylinder(r = roundness, h = height, center = false, $fn = 20);
  }
  rect_x_shift = (anchor_corner == CORNER_SW || anchor_corner == CORNER_NW) ? roundness : 0;
  rect_y_shift = (anchor_corner == CORNER_SW || anchor_corner == CORNER_SE) ? roundness : 0;
  translate([rect_x_shift, 0, 0]) cube([size - roundness, size, height], center = false);
  translate([0, rect_y_shift, 0]) cube([size, size - roundness, height], center = false);
}

module day_pillar(size, roundness, segments_unsorted, height) {
  segments = quicksort_segments(segments_unsorted);
  segment0_height = max((segments[0][1] - min_visible_depth), 0);
  segment1_height = max((segments[1][1] - min_visible_depth), 0);
  segment2_height = max((segments[2][1] - min_visible_depth), 0);
  segment3_height = max((segments[3][1] - min_visible_depth), 0);
  union() {
    if (segment0_height > 0 && segment0_height < height) {
      cube([size, size, segment0_height]);
    }
    if (segment1_height > 0 && segment1_height < height) {
      intersection() {
        cube([size, size, segment1_height]);
        rounded_corner_cube(size, segments[0][0], roundness, height);
      }
    }
    if (segment2_height > 0 && segment2_height < height) {
      intersection() {
        cube([size, size, segment2_height]);
        rounded_corner_cube(size, segments[0][0], roundness, height);
        rounded_corner_cube(size, segments[1][0], roundness, height);
      }
    }
    if (segment3_height > 0) {
      intersection() {
        cube([size, size, segment3_height]);
        rounded_corner_cube(size, segments[0][0], roundness, height);
        rounded_corner_cube(size, segments[1][0], roundness, height);
        rounded_corner_cube(size, segments[2][0], roundness, height);
      }
    }
    rounded_cube(size, size / 8, height);
  }
}

// Draw the baseplate
color("red") difference() {
  for (i = [0:len(padded_data) - 1]) {
    day_count = padded_data[i];
    if (day_count != -1) {
      translate([cell_x(i), cell_y(i), 0]) {
        cube([day_width, day_width, baseplate_thickness]);
      }
    }
  }
  // Optional: emboss text (e.g. the year) into the base
  if (add_text) {
    use_font_size = font_size != 0 ? font_size : day_width * (days_per_column - 2);
    translate([day_width + 1, day_width, 1]) {
      rotate(a=[0,180,0]) {
        linear_extrude(height = 1.1) {
          text(base_label, size = use_font_size, font = "Public Sans:style=Bold", spacing = 0.95, halign = "right", valign = "baseline");
        }
      }
    }
  }
}

// Draw the towers
for (i = [0:len(padded_data) - 1]) {
  if (padded_data[i] != -1) {
    day_count = round_data ? ceil(padded_data[i] / 10) * 10 : padded_data[i];
    // day_height = day_count * scale_z;
    day_height = day_count != 0 ? max(day_count * scale_z, min_layer_height) : 0;

    if (tower_gaps) {
      row = row_number(i);
      col = column_number(i);
      // Compute the height of each neighbor
      // to build a "solid" base on as many 
      // sides (for as much height) as possible
      north_index = i - 1;
      south_index = i + 1;
      west_index = i - days_per_column;
      east_index = i + days_per_column;
      northwest_index = west_index - 1;
      southwest_index = west_index + 1;
      northeast_index = east_index - 1;
      southeast_index = east_index + 1;

      has_north = row > 0;
      has_south = row < (days_per_column - 1);
      has_west = col > 0;
      has_east = i < (len(padded_data) - days_per_column);

      north = has_north ? padded_data[north_index] : 0;
      south = has_south ? padded_data[south_index] : 0;
      west = has_west ? padded_data[west_index] : 0;
      east = has_east ? padded_data[east_index] : 0;
      northwest = has_north && has_west ? padded_data[northwest_index] : 0;
      southwest = has_south && has_west ? padded_data[southwest_index] : 0;
      northeast = has_north && has_east ? padded_data[northeast_index] : 0;
      southeast = has_south && has_east ? padded_data[southeast_index] : 0;

      min_nw = min([day_count, west, northwest, north]);
      min_ne = min([day_count, north, northeast, east]);
      min_sw = min([day_count, west, southwest, south]);
      min_se = min([day_count, south, southeast, east]);

      day_segments = [
        [CORNER_SW, min_sw * scale_z],
        [CORNER_NW, min_nw * scale_z],
        [CORNER_SE, min_se * scale_z],
        [CORNER_NE, min_ne * scale_z],
      ];

      translate([cell_x(i), cell_y(i), baseplate_thickness]) {
        day_pillar(day_width, day_width / 8, day_segments, day_height);
      }
    } else {
      translate([cell_x(i), cell_y(i), baseplate_thickness]) {
        cube([day_width, day_width, day_height]);
      }
    }
  }
}
