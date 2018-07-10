%% PlotMeshSurface
% Creates a 3D surface mesh visualization.
%
%% Description
% |PlotMeshSurface(mesh, infoVol)| creates a 3D visualization of the
% surface mesh |mesh|, described by the space |infoVol|. If no region data
% is provided in |mesh.region|, all nodes will be assumed to form a single
% region.
%
% |PlotMeshSurface(mesh, infoVol, params)| allows the user to specify
% parameters for plot creation.
%
%% Visualization Parameters
% |params| fields that apply to this function (and their defaults):
%
% <html>
% <table border = 1>
% <tr><td>Name</td><td>Default</td><td>Effect</td></tr>
% <tr><td>fig_size</td><td>[20, 200, 1240, 420]</td><td>Default figure
% position vector.</td></tr>
% <tr><td>fig_handle</td><td>(none)</td><td>Specifies a figure to
% target.</td></tr>
% <tr><td>Nregs</td><td>(unique(mesh.region)) or 1</td><td>Number of
% regions to display. If 0 is given, all region data will be ignored and a
% matte gray surface plotted.</td></tr>
% <tr><td>TC</td><td>1</td><td>Direct map integer data values to defined
% color map ("True Color").</td></tr>
% <tr><td>Cmap.P</td><td>'jet'</td><td>Colormap for positive data
% values.</td></tr>
% <tr><td>BG</td><td>[0.8, 0.8, 0.8]</td><td>Background color, as an RGB
% triplet.</td></tr>
% <tr><td>orientation</td><td>'t'</td><td>Select orientation of volume. 't'
% for transverse, 's' for sagittal.</td></tr>
% </table>
% </html>
%
% Note: |applycmap| has further options for using |params| to specify
% parameters for the fusion, scaling, and colormapping process.
%
%% Dependencies
% <applycmap_help.html applycmap>
%
%% See Also
% <PlotSlices_help.html PlotSlices> | <PlotCap_help.html PlotCap> |
% <Cap_Fitter_help.html Cap_Fitter>