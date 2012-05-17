function t = delaunay3(x,y,z,options)
%DELAUNAY3  3-D Delaunay triangulation.
%
%   DELAUNAY3 will be removed in a future release. Use DelaunayTri instead.
%
%   T = DELAUNAY3(X,Y,Z) returns a set of tetrahedra such that no data
%   points of X are contained in any circumspheres of the tetrahedra. T is
%   a numt-by-4 array. The entries in each row of T are indices of the
%   points in (X,Y,Z) forming a tetrahedron in the triangulation of (X,Y,Z).
%
%   T = DELAUNAY3(X,Y,Z,OPTIONS) specifies a cell array of strings OPTIONS
%   that were previously used by Qhull. Qhull-specific OPTIONS are no longer 
%   required and are currently ignored.
%
%   Example:
%      X = [-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5];
%      Y = [-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5];
%      Z = [-0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5];
%      T = delaunay3( X, Y, Z )
%
%   See also DelaunayTri, TriScatteredInterp, DELAUNAY, DELAUNAYN, GRIDDATAN,
%            VORONOIN, TETRAMESH.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.12 $ $Date: 2009/09/03 05:25:13 $


% warning('MATLAB:delaunay3:DeprecatedFunction',...
% 'DELAUNAY3 will be removed in a future release. Use DelaunayTri instead.');

if nargin < 3
    error('MATLAB:delaunay3:NotEnoughInputs','Needs at least 3 inputs.');
end

if ~isequal(size(x),size(y),size(z))
    error('MATLAB:delaunay3:InputSizeMismatch',...
          'X,Y,Z have to be the same size.');
end

if ndims(x) > 3 || ndims(y) > 3 || ndims(z) > 3
    error('MATLAB:delaunay3:HigherDimArray',...
          'X,Y,Z cannot be arrays of dimension greater than three.');
end

warning('MATLAB:delaunay3:DeprecatedFunction',...
        'DELAUNAY3 will be removed in a future release. Use DelaunayTri instead.');
    
X = [x(:) y(:) z(:)];

if( nargin > 3)
  cg_opt = options;
else
    cg_opt = {};
end

cgprechecks(X, nargin-1, cg_opt);

[X, dupesfound, idxmap] = mergeDuplicatePoints(X);
if dupesfound
    warning('MATLAB:delaunay3:DuplicateDataPoints',['Duplicate data points have been detected.\n',...
                                                    'Some data points do not map to vertices in the triangulation.\n',...
                                                    'To avoid this behavior, call UNIQUE on the data points prior to calling DELAUNAY.']);
end
[m,n] = size(X);

if m < n+1,
  error('MATLAB:delaunay3:NotEnoughPtsForTessel',...
        'Not enough unique points to create a triangulation.');
end

dt = DelaunayTri(X);
scopedWarnOff = warning('off', 'MATLAB:TriRep:EmptyTri3DWarnId');
restoreWarnOff = onCleanup(@()warning(scopedWarnOff));
t = dt.Triangulation;
if isempty(t)
  error('MATLAB:delaunay3:EmptyTriangulation','Error computing Delaunay triangulation. The points may be coplanar or collinear.');
end
% Rewire the triangle indices if points were merged
if (dupesfound)
    t = idxmap(t);
end


