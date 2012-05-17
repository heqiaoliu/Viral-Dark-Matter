function conformalShowLines(axIn, axOut, t1, t2)
% conformalShowLines Plot a grid of lines before/after transformation.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:53 $

d = 1/16;
u1 = [-5/4 : d : -d, -1e-6];
u2 =    0  : d : 5/4;
v1 = [-3/4 : d : -d, -1e-6];
v2 =    0  : d : 3/4;

% Lower left quadrant
[U,V] = meshgrid(u1,v1);
color = [0.3 0.3 0.3];
plotMesh(axIn,U,V,color);
plotMesh(axOut,tformfwd(t1,U,V),color);
plotMesh(axOut,tformfwd(t2,U,V),color);

% Upper left quadrant
[U,V] = meshgrid(u1,v2);
color = [0 0 0.8];
plotMesh(axIn,U,V,color);
plotMesh(axOut,tformfwd(t1,U,V),color);
plotMesh(axOut,tformfwd(t2,U,V),color);

% Lower right quadrant
[U,V] = meshgrid(u2,v1);
color = [0 0.8 0];
plotMesh(axIn,U,V,color);
plotMesh(axOut,tformfwd(t1,U,V),color);
plotMesh(axOut,tformfwd(t2,U,V),color);

% Upper right quadrant
[U,V] = meshgrid(u2,v2);
color = [0 0.7 0.7];
plotMesh(axIn,U,V,color);
plotMesh(axOut,tformfwd(t1,U,V),color);
plotMesh(axOut,tformfwd(t2,U,V),color);

%-------------------------------------------------------------

function plotMesh(varargin)
% Plots a mesh on the axes AX with color COLOR, via calls
% to 'LINE'.
%
%  PLOTMESH(AX,X,Y,COLOR) accepts two M-by-N arrays X and Y
%  -- like the output of MESHGRID.
%
%  PLOTMESH(AX,XY,COLOR) accepts a single M-by-N-by-2 array XY
%  -- like the output of TFORMFWD.

if nargin == 3
  ax = varargin{1};
  XY = varargin{2};
  color = varargin{3};
  X = XY(:,:,1);
  Y = XY(:,:,2);
else
  ax = varargin{1};
  X  = varargin{2};
  Y  = varargin{3};
  color = varargin{4};
end
  
for k = 1:size(X,1)
    line(X(k,:),Y(k,:),'Parent',ax,'Color',color);
end

for k = 1:size(X,2)
    line(X(:,k),Y(:,k),'Parent',ax,'Color',color);
end
