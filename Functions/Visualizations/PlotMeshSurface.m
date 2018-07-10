function PlotMeshSurface(mesh, infoVol, params)

% PLOTMESHSURFACE Creates a 3D surface mesh visualization.
% 
%   PLOTMESHSURFACE(mesh, infoVol) creates a 3D visualization of the
%   surface mesh "mesh", described by the space "infoVol". If no region
%   data is provided in "mesh.region", all nodes will be assumed to form a
%   single region.
% 
%   PLOTMESHSURFACE(mesh, infoVol, params) allows the user to
%   specify parameters for plot creation.
%
%   "params" fields that apply to this function (and their defaults):
%       fig_size    [20, 200, 1240, 420]        Default figure position
%                                               vector.
%       fig_handle  (none)                      Specifies a figure to
%                                               target.
%       Nregs       (unique(mesh.region)) or 1  Number of regions to
%                                               display. If 0 is given, all
%                                               region data will be ignored
%                                               and a matte gray surface
%                                               plotted.
%       TC          1                           Direct map integer data
%                                               values to defined color map
%                                               ("True Color").
%       Cmap.P      'jet'                       Colormap for positive data
%                                               values.
%       BG          [0.8, 0.8, 0.8]             Background color, as an RGB
%                                               triplet.
%       orientation 't'                         Select orientation of
%                                               volume. 't' for transverse,
%                                               's' for sagittal.
% 
%   Note: APPLYCMAP has further options for using "params" to specify
%   parameters for the fusion, scaling, and colormapping process.
% 
% Dependencies: APPLYCMAP
% 
% See Also: PLOTSLICES, PLOTCAP, CAP_FITTER.

%% Parameters and Initialization
LineColor = 'w';
BkgdColor = 'k';
new_fig = 0;

if exist('infoVol', 'var')
    if isfield(infoVol, 'acq')
        params.orientation = infoVol.acq(1);
    end
end

if ~exist('params', 'var')
    params = [];
end

if ~isfield(mesh, 'region')  ||  isempty(mesh.region)
    % Assume it's all one region if no region info given.
    mesh.region = ones(size(mesh.nodes, 1), 1);
    if ~isfield(params, 'Nregs')  ||  isempty(params.Nregs)
        params.Nregs = 1;
    end
else
    if ~isfield(params, 'Nregs')  ||  isempty(params.Nregs)
        params.Nregs = max(unique(mesh.region));
    end
end

if ~isfield(params, 'fig_size')  ||  isempty(params.fig_size)
    params.fig_size = [20, 200, 560, 560];
end
if ~isfield(params, 'fig_handle')  ||  isempty(params.fig_handle)
    params.fig_handle = figure('Color', BkgdColor, 'Position', params.fig_size);
    new_fig = 1;
else
    switch params.fig_handle.Type
        case 'figure'
            set(groot, 'CurrentFigure', params.fig_handle);
        case 'axes'
            set(gcf, 'CurrentAxes', params.fig_handle);
    end
end
if ~isfield(params, 'TC')  ||  isempty(params.TC)
    params.TC = 1;
end
if ~isfield(params, 'Cmap')  ||  isempty(params.Cmap) ||...
        (isfield(params.Cmap, 'P')  &&  isempty(params.Cmap.P))
    params.Cmap.P = 'jet';
else
    if ~isstruct(params.Cmap)
        temp = params.Cmap;
        params.Cmap = [];
        params.Cmap.P = temp;
    end
end
if ischar(params.Cmap.P) % Generate special cmap before applycmap can get to it.
    if numel(params.Nregs) == 1 % Makes the default color yellow.
        params.DR = 5;
    else 
        params.DR = numel(params.Nregs) + 2;
    end
    params.Cmap.P = eval([params.Cmap.P, '(', num2str(params.DR), ');']);
    if params.Nregs == 1
        params.Cmap.P(1, :) = [];
        params.Cmap.P(1, :) = []; % Makes the default color yellow.
    end
    params.Cmap.P(1, :) = [];
    params.Cmap.P(end, :) = [];
elseif isnumeric(params.Cmap.P)
    params.Cmap.P = params.Cmap.P;
end
if ~isfield(params, 'BG')  ||  isempty(params.BG)
    params.BG = [0.8, 0.8, 0.8];
end
if ~isfield(params, 'orientation')  ||  isempty(params.orientation)
    params.orientation = 's';
end

% % %% Select region.
% % keep_nodes = ismember(mesh.region, params.Nregs);
% % nodes_sel = mesh.nodes(keep_nodes, :);
% % 
% % keep_elems = all(ismember(mesh.elements, find(keep_nodes)), 2);
% % elements_sel = mesh.elements(keep_elems, :);

%% Get face centers of elements for S/D pairs.
switch size(mesh.elements, 2)
    case 4
        TR = triangulation(mesh.elements, mesh.nodes);
        [elements_free, nodes_free] = freeBoundary(TR);
    case 3
        nodes_free = mesh.nodes;
        elements_free = mesh.elements;
end

if params.Nregs == 0
    FaceColor = [0.5, 0.5, 0.5];
    EdgeColor = BkgdColor;
    FaceLighting = 'flat';
    AmbientStrength = 0.5;
    DiffuseStrength = 0.6;
    SpecularStrength = 0.9;
    FV_CData = [];
else
    FaceColor = 'interp';
    EdgeColor = BkgdColor;
    FaceLighting = 'gouraud';
    AmbientStrength = 0.25;
    DiffuseStrength = 0.5;
    SpecularStrength = 0.1;
    
    [~, Ia] = ismember(nodes_free, mesh.nodes, 'rows'); % Get locations of free nodes.
    Ia(Ia == 0) = []; % Clear zero indices.
    Ib = ismember(mesh.region(Ia), params.Nregs); % Get free nodes that are in Nregs' regions.
    reg = mesh.region(Ia(Ib)); % Get regions of those nodes for coloring.
    
    nodes_free = nodes_free(Ib, :); % Select those nodes for patching.
    
    [FV_CData, CMAP] = applycmap(reg - min(mesh.region) + 1, [], params);
end

%% Create visualization.
h = patch('Faces', elements_free, 'Vertices', nodes_free,...
    'EdgeColor', EdgeColor, 'FaceColor', FaceColor,...
    'FaceVertexCData', FV_CData, 'FaceLighting', FaceLighting,...
    'AmbientStrength', AmbientStrength, 'DiffuseStrength', DiffuseStrength,...
    'SpecularStrength', SpecularStrength);

set(gca, 'Color', params.BG, 'XTick', [], 'YTick', [], 'ZTick', []);

switch params.orientation
    case 's'
        set(gca, 'ZDir', 'rev');
    case 't'
        set(gca, 'XDir', 'rev');
    case 'c'
        set(gca, 'YDir', 'rev');
end

axis image
% axis off
hold on
rotate3d on

if new_fig
    title('Surface of Input Mesh', 'Color', LineColor, 'FontSize', 12)
end

%% Set additional lighting
% Lower lighting
light('Position', [-140, 90, -100], 'Style', 'local')
light('Position', [-140, -350, -100], 'Style', 'local')
light('Position', [300, 90, -100], 'Style', 'local')
light('Position', [300, -350, -100], 'Style', 'local')

% Higher lighting
light('Position', [-140, 90, 360], 'Style', 'local');
light('Position', [-140, -350, 360], 'Style', 'local');
light('Position', [300, 90, 360], 'Style', 'local');
light('Position', [300, -350, 360], 'Style', 'local');

xlabel('X', 'Color', LineColor)
ylabel('Y', 'Color', LineColor)
zlabel('Z', 'Color', LineColor)

if new_fig
    view(163, 20)
end



%
