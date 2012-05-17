function [msg,nx,ny,nz] = xyzuvwcheck(x,y,z,u,v,w)
%XYZUVWCHECK  Check arguments to 3D vector data routines.
%   [MSG,X,Y,Z] = XYZUVWCHECK(X,Y,Z,U,V,W) checks the input arguments
%   and returns either an error message structure in MSG or valid 
%   X,Y,Z. The ERROR function describes the format and use of the
%   error structure.
%
%   See also ERROR

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.6.4.2 $  $Date: 2009/11/13 04:37:57 $

msg = struct([]);
nx = x;
ny = y;
nz = z;

sz = size(u);
if ~isequal(size(v), sz) || ~isequal(size(w), sz)
  msg = makemsg('UVWSizeMismatch','U,V,W must all be the same size.');
  return
end

if ndims(u)~=3
  msg = makemsg('UVWNot3D','U,V,W must all be a 3D arrays.');
  return
end
if min(sz)<2
  msg = makemsg('UVWPlanar','U,V,W must all be size 2x2x2 or greater.'); 
  return
end

nonempty = ~[isempty(x) isempty(y) isempty(z)];
if any(nonempty) && ~all(nonempty)
  msg = makemsg('XYZMixedEmpty','X,Y,Z must all be empty or all non-empty.');
  return;
end

if ~isempty(nx) && ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg = makemsg('XUSizeMismatch','The size of X must match the size of U or the number of columns of U.');
    return
  else
    nx = repmat(nx',[sz(1) 1 sz(3)]);
  end
end

if ~isempty(ny) && ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg = makemsg('YUSizeMismatch','The size of Y must match the size of U or the number of rows of U.');
    return
  else
    ny = repmat(ny,[1 sz(2) sz(3)]);
  end
end

if ~isempty(nz) && ~isequal(size(nz), sz)
  nz = nz(:);
  if length(nz)~=sz(3)
    msg = makemsg('ZUSizeMismatch','The size of Z must match the size of U or the number of pages of U.');
    return
  else
    nz = repmat(reshape(nz,[1 1 length(nz)]),[sz(1) sz(2) 1]);
  end
end

function msg = makemsg(id,str)
msg.identifier = ['MATLAB:xyzuvwcheck:' id];
msg.message = str;
