function [msg,nx,ny] = xyuvcheck(x,y,u,v)
%XYUVCHECK  Check arguments to 2D vector data routines.
%   [MSG,X,Y] = XYUVCHECK(X,Y,U,V) checks the input arguments
%   and returns either an error message structure in MSG 
%   or valid X,Y. The ERROR function describes the format 
%   and use of the error structure.
%
%   See also ERROR

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2009/11/13 04:37:55 $

msg = struct([]);
nx = x;
ny = y;

sz = size(u);
if ~isequal(size(v), sz)
  msg = makemsg('UVSizeMismatch','U,V must all be the same size.');
  return
end

if ndims(u)~=2
  msg = makemsg('UVNot2D','U,V must all be a 2D arrays.');
  return
end
if min(sz)<2
  msg = makemsg('UVPlanar','U,V must all be size 2x2 or greater.'); 
  return
end

nonempty = ~[isempty(x) isempty(y)];
if any(nonempty) && ~all(nonempty)
  msg = makemsg('XYMixedEmpty','X,Y must both be empty or both non-empty.');
  return;
end

if ~isempty(nx) && ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg = makemsg('XUSizeMismatch','The size of X must match the size of U or the number of columns of U.');
    return
  else
    nx = repmat(nx',[sz(1) 1]);
  end
end

if ~isempty(ny) && ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg = makemsg('YUSizeMismatch','The size of Y must match the size of U or the number of rows of U.');
    return
  else
    ny = repmat(ny,[1 sz(2)]);
  end
end

function msg = makemsg(id,str)
msg.identifier = ['MATLAB:xyuvcheck:' id];
msg.message = str;
