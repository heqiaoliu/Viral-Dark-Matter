function k = dsearch(varargin)
%DSEARCH Search Delaunay triangulation for nearest point.
%
%   DSEARCH will be removed in a future release.
%   Use DelaunayTri/nearestNeighbor instead.
%
%   K = DSEARCH(X,Y,TRI,XI,YI) returns the index of the nearest (x,y)
%   point to the point (xi,yi). Requires a triangulation TRI of
%   the points X,Y obtained from DELAUNAY.
%
%   K = DSEARCH(X,Y,TRI,XI,YI,S) uses the sparse matrix S instead of
%   computing it each time:
%   
%     S = sparse(tri(:,[1 1 2 2 3 3]),tri(:,[2 3 1 3 1 2]),1,nxy,nxy) 
%
%   where nxy = prod(size(x)).
%
%   See also DelaunayTri, DELAUNAY, VORONOI.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2009/09/03 05:25:15 $

%   This calls a MATLAB mex file.
warning('MATLAB:dsearch:DeprecatedFunction',...
        'DSEARCH will be removed in a future release. Use DelaunayTri/nearestNeighbor instead.');
k = dsrchmx(varargin{:});
