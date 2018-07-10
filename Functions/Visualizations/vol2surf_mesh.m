function mesh_out = vol2surf_mesh(mesh_in, volume, dim, params)

% VOL2SURF_MESH Interpolates volumetric data onto a surface mesh.
% 
%   mesh_out = VOL2SURF_MESH(mesh_in, volume, dim) takes the mesh "mesh_in"
%   and interpolates the values of the volumetric data "volume" at the
%   mesh's surface, using the spatial information in "dim". These values
%   are overwritten in a new mesh, which is output as "mesh_out".
% 
%   mesh_out = VOL2SURF_MESH(mesh_in, volume, dim, params) allows the user
%   to specify parameters for plot creation.
%
%   "params" fields that apply to this function (and their defaults):
%       OL      0   If "overlap" data is presented (OL==1), this sets the
%                   interpolation method to "nearest". Default is "linear".
% 
% See Also: PLOTINTERPSURFMESH, GOOD_VOX2VOL, AFFINE3D_IMG.

%% Parameters and Initialization.
Ncols = size(volume, 4);
Ncoords = size(mesh_in.nodes, 1);
mesh_out = mesh_in;
mesh_out.data = zeros(Ncoords, Ncols);
extrapval = 0;

nVx = dim.nVx;
nVy = dim.nVy;
nVz = dim.nVz;
dr = dim.mmppix;
center = dim.center;

if ~exist('params', 'var')  ||  isempty(params)
    params = [];
end

if ~isfield(params, 'OL')  ||  isempty(params.OL)
    params.OL = 0;
end
if params.OL
    method = 'nearest';
else
    method = 'linear';
end

%% Define coordinate space of volumetric data
X = (-center(1) + nVx * dr(1):-dr(1):-center(1) + dr(1))'; %R2L -dr(1)/2
Y = (-center(2) + nVy * dr(2):-dr(2):-center(2) + dr(2))'; %V2D -dr(2)/2
Z = (-center(3) + nVz * dr(3):-dr(3):-center(3) + dr(3))'; %P2A -dr(3)/2

%% Get coordinates for surface mesh
x = mesh_in.nodes(:, 1);
y = mesh_in.nodes(:, 2);
z = mesh_in.nodes(:, 3);

%% Correct for nodes just outside of volume (MNI and TT atlas space cuts off occipital pole and part of dorsal tip and lateral extremes).
x(x < min(X)) = min(X);
x(x > max(X)) = max(X);

y(y < min(Y)) = min(Y);
y(y > max(Y)) = max(Y);

z(z < min(Z)) = min(Z);
z(z > max(Z)) = max(Z);

%% Interpolate
for k = 1:Ncols
    mesh_out.data(:, k) = interp3(Y, X, Z, squeeze(volume(:, :, :, k)), y, x, z, method, extrapval);
end



%
