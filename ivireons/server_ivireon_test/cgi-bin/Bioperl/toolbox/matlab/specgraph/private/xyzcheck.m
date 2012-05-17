function [msg,nx,ny] = xyzcheck(x,y,z,zname)
%XYZCHECK  Check arguments to 2.5D data routines.
%   [MSG,X,Y] = XYZCHECK(X,Y,Z) checks the input arguments
%   and returns either an error message structure in MSG or 
%   valid X,Y. The ERROR function describes the format and 
%   use of the error structure.
%
%   See also ERROR

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2009/11/13 04:37:56 $

msg = struct([]);
nx = x;
ny = y;

sz = size(z);

if nargin < 4
    zname = 'Z';
end

if ndims(z)~=2
  msg = makemsg('ZNot2D',sprintf('%s must be a 2D array.',zname));
  return
end
if min(sz)<2
  msg = makemsg('ZPlanar',sprintf('%s must be size 2x2 or greater.',zname)); 
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
    msg = makemsg('XZSizeMismatch',sprintf('The size of X must match the size of %s or the number of columns of %s.',zname,zname));
    return
  else
    nx = repmat(nx',[sz(1) 1]);
  end
end

if ~isempty(ny) && ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg = makemsg('YZSizeMismatch',sprintf('The size of Y must match the size of %s or the number of rows of %s.',zname,zname));
    return
  else
    ny = repmat(ny,[1 sz(2)]);
  end
end

function msg = makemsg(id,str)
msg.identifier = ['MATLAB:xyzcheck:' id];
msg.message = str;
