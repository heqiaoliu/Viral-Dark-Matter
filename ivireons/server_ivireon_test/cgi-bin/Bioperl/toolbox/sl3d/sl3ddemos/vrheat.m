%% Heat Transfer Visualization
% This demonstration illustrates the use of the Simulink(R) 3D Animation(TM)
% with the MATLAB(R) interface for manipulating complex objects.   
%
% In this demonstration, matrix-type data is transferred between MATLAB and
% a virtual reality world. Using this feature, you can achieve massive
% color changes or morphing. This is useful for visualizing various
% physical processes. 
%
% We use precalculated data of time-based temperature distributions in an
% L-shaped metal block and send that data to the virtual world. This forms
% an animation with relatively large changes.

% Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/23 16:43:48 $ $Author: batserve $

%% Load the Precalculated Data

load('vrheat.mat');

%% Reshaping the Object for VRML
% The geometry of the L-shaped block is stored in the 'lblock' structure.
% For visualization purposes, the block is subdivided into triangular
% facets.  Surface facet vertex coordinates are stored in the
% 'lblock.mesh.p' field and triangle edges are described by indices into
% the vertex array.

vert = lblock.mesh.p';

%%
% A set of facets in VRML is defined as a single vector of vertex indices
% where facets are separated by -1, so we need to transform the vertex
% array appropriately. Indexes in VRML are zero-based, so 1 is deducted
% from all index values stored originally in the 1-based index array
% lblock.mesh.e.

facets = lblock.mesh.e(1:3,:)-1;
facets(4,:) = -1;
f = facets; f = f(:);
facets = facets';

%% Prepare the Colormap
% Now we'll prepare a colormap that represents various levels of
% temperature.  The MATLAB built-in 'jet' colormap is designed for these
% purposes.

cmap = jet(192);

%% Apply the Colormap
% The 'lblock.sol.u' field contains a matrix describing the temperatures of
% vertices as time passes. We have 41 precalculated phases (1 is
% initial) for 262 vertices. We need to scale the temperature values so 
% that they map into the colormap.

u = lblock.sol.u;
ucolor = (u-repmat(min(u),size(u,1),1)) .* (size(cmap,1)-1); 
urange = max(u) - min(u);
urange(urange == 0) = 1;
ucolor = round(ucolor./repmat(urange,size(u,1),1));

%%
% We will calculate the first animation frame so we have something to begin
% with.

uslice=ucolor(:,1);
colind=zeros(size(facets));
colind(:,1:3)=uslice(facets(:,1:3)+1);
colind(:,4)=-1;
ci = colind'; 
ci = ci(:);

%%
% The data is ready so we can load the world.

world = vrworld('vrheat.wrl'); 
open(world);

%%
% Let's start the viewer. A cube should appear in the viewer window.

fig = view(world, '-internal'); 
vrdrawnow;

%%
% Now we'll prepare the L-shaped block. The VRML world that we loaded
% contains a basic cubic form that we can reshape into anything we want
% by setting its 'point' and 'coordIndex' fields, which represent
% the vertex coordinates and indices into the vertex array.
% We will also set the colors by setting the 'color' and 'colorIndex'
% fields.
%
% We first set the colors, the color indices, the vertices,
% and then the vertex indices. The order is not mandatory but it is
% generally better this way because we can be sure there is no temporary
% state when there are more vertices than colors, or more indices than
% values, which would cause some vertices to have undefined color or some
% indices referring to nonexisting (yet) values.

world.IFS_Colormap.color = cmap;
world.IFS.colorIndex = ci;
world.IFS_Coords.point = vert;
world.IFS.coordIndex = f;

%% Working with VRML Text Objects
% The textual comment can also be set to something sensible.

world.TEXT.string = {'Time = 0'}; 
vrdrawnow;

%% Animate the Scene
% Now we can start the animation. Watch it in the viewer.
% You can move around the object, or try to set other rendering modes.
% E.g., a wireframe mode which demonstrates how the L-block is subdivided.

for i = 1:size(u,2)
    pause(0.2);
    uslice = ucolor(:,i);
    colind = zeros(size(facets));
    colind(:,1:3) = uslice(facets(:,1:3)+1);
    colind(:,4) = -1;
    ci=colind';
    ci=ci(:);
    world.IFS.colorIndex = ci;
    world.TEXT.string = {sprintf('Time = %g', lblock.sol.tlist(i))};
    vrdrawnow;
end

%% Preserve the Virtual World Object in the MATLAB(R) Workspace 
% After you are done with a VRWORLD object, it is necessary to close and
% delete it.  This is accomplished by using the CLOSE and DELETE commands.
%
% close(world);
% delete(world);
%
% However, we will not do it here. Instead, we leave the world open so
% that you can play with it further. We will clear only the used global variables.

clear ans ci cm cmap colind f facets i lblock nh u ucolor;
clear urange uslice v vert;


displayEndOfDemoMessage(mfilename)
