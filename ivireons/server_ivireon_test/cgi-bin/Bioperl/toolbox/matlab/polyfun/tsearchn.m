function [t, p] = tsearchn(x,tes,xi)
%TSEARCHN N-D closest simplex search.
%   T = TSEARCHN(X,TES,XI) returns the indices T of the enclosing simplex
%   of the Delaunay tessellation TES for each point in XI. X is 
%   an m-by-n matrix, representing m points in n-D space. XI is 
%   a p-by-n matrix, representing p points in n-D space.  TSEARCHN returns 
%   NaN for all points outside the convex hull of X. TSEARCHN requires a 
%   tessellation TES of the points X obtained from DELAUNAYN.
% 
%   [T,P] = TSEARCHN(X,TES,XI) also returns the barycentric coordinate P
%   of XI in the simplex TES. P is an p-by-n+1 matrix. Each row of P is the
%   barycentric coordinate of the corresponding point in XI. It is useful
%   for interpolation.
%
%   See also DelaunayTri, DSEARCHN, QHULL, GRIDDATAN, DELAUNAYN.

%   Relies on the MEX file tsrchnmx to do most of the work.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.13.4.7 $  $Date: 2009/09/03 05:25:24 $

myeps = -sqrt(eps);
[npt ndim] = size(xi); % Number of points
ntri = size(tes,1); % Number of simplexes

if size(x,2) ~= ndim
    error('MATLAB:tsearchn:InvalidDimensions',...
        'X and XI must have the same number of columns.')
elseif size(tes,2) ~= ndim+1
    error('MATLAB:tsearchn:InvalidTessellation',...
        'The tessellation TES must have one more column than X.')
end

% Heuristic for determining whether to use MEX-file
if npt > 100
    mult = 1;
else
    mult = npt/100;
end
use_m_file = ntri < (mult*10^ndim);

if use_m_file
    t = nan(npt,1); % Simplex containing corresponding input point
    p = nan(npt,ndim+1); % Barycentric coordinates for corresponding input point
    X = [ones(size(x,1),1) x]; % Append 1s to vertex matrix
    b = [ones(npt,1) xi]; % Append 1s to point matrix
    for i = 1:ntri
        % For each triangle
        q = b / X(tes(i,:),:); % Compute barycentric coordinate of each point
        I = all(q > myeps,2); % Find simplex where all coordinates are positive
        t(I) = i; % Set simplex
        p(I,:) = q(I,:); % Set barycentric coordinates
    end
else
  if nargout == 2
    [t,p] = tsrchnmx(x',tes,xi',0);
    p = p';
  else
    t = tsrchnmx(x',tes,xi',2);
  end
end
