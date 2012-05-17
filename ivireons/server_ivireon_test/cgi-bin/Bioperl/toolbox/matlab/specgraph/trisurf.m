function hh = trisurf(tri,varargin)
%TRISURF Triangular surface plot
%   TRISURF(TRI,X,Y,Z,C) displays the triangles defined in the M-by-3
%   face matrix TRI as a surface.  A row of TRI contains indexes into
%   the X,Y, and Z vertex vectors to define a single triangular face.
%   The color is defined by the vector C.
%
%   TRISURF(TRI,X,Y,Z) uses C = Z, so color is proportional to surface
%   height.
%
%   TRISURF(TR) displays the triangles in a TriRep - a Triangulation 
%               representation. It uses C = TR.X(:,3), to color the  
%               surface proportional to height.
%
%   H = TRISURF(...) returns a patch handle.
%
%   TRISURF(...,'param','value','param','value'...) allows additional
%   patch param/value pairs to be used when creating the patch object. 
%
%   Example:
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trisurf(tri,x,y,z)
%
%   % Alternatively, if the surface is in the form of a TriRep,
%   % a triangulation representation, it may be plotted as follows;
%   tr = TriRep(tri, x(:), y(:), z(:));
%   trisurf(tr)
%
%   See also PATCH, TRIMESH, DELAUNAY, TriRep, DelaunayTri.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.15.4.5 $  $Date: 2009/10/24 19:18:41 $

error(nargchk(1,inf,nargin,'struct'));

ax = axescheck(varargin{:});
ax = newplot(ax);
start = 1;

if isa(tri, 'TriRep')
     if tri.size(1) == 0
        error('MATLAB:triplot:EmptyTri',...
          'The triangulation is empty.');
     elseif tri.size(2) ~= 3
        error('MATLAB:triplot:NonTriangles',...
          'The triangulation must be composed of triangles.');
     elseif size(tri.X, 2) ~= 3
        error('MATLAB:triplot:NonSurfTri',...
          'The triangulation must reside in 3D space.');
     end
     x = tri.X(:,1);
     y = tri.X(:,2);
     z = tri.X(:,3);
     trids = tri(:,:);
     if (nargin == 1) || (mod(nargin-1,2) == 0)
       c = z;
     else
       c = varargin{1};
       start = 2;
     end
else
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    trids = tri;
    if nargin>4 && rem(nargin-4,2)==1, 
      c = varargin{4};
      start = 5;
    else
      c = z;
      start = 4;
    end
end
h = patch('faces',trids,'vertices',[x(:) y(:) z(:)],'facevertexcdata',c(:),...
      'facecolor',get(ax,'DefaultSurfaceFaceColor'), ...
      'edgecolor',get(ax,'DefaultSurfaceEdgeColor'),'parent',ax,...
      varargin{start:end});
if ~ishold(ax), view(ax,3), grid(ax,'on'), end
if nargout==1, hh = h; end

