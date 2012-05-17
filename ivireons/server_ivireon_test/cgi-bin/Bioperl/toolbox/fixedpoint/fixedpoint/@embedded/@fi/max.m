function [Y,varargout] = max(varargin)
%MAX    Largest component
%   For vectors, MAX(X) is the largest element in X. For matrices,
%   MAX(X) is a row vector containing the maximum element from each
%   column. For N-D arrays, MAX(X) operates along the first
%   non-singleton dimension.
%
%   [Y,I] = MAX(X) returns the indices of the maximum values in vector I.
%   If the values along the first non-singleton dimension contain more
%   than one maximal element, the index of the first one is returned.
%
%   MAX(X,Y) returns an array the same size as X and Y with the
%   largest elements taken from X or Y.  Either one can be a scalar.
%
%   [Y,I] = MAX(X,[],DIM) operates along the dimension DIM. 
%
%   When complex, the magnitude MAX(ABS(X)) is used, and the angle
%   ANGLE(X) is ignored.  NaN's are ignored when computing the maximum.
%
%   See also EMBEDDED.FI/MIN

%   Thomas A. Bryan, 16 April 2003
%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/10/24 19:04:07 $

error(nargchk(1,inf,nargin,'struct'));
error(nargoutchk(0,2,nargout,'struct'));

if nargin==1
  % Y     = max(A)
  % [Y,I] = max(A)
  % Work on first non-singleton dimension
  [A,perm,nshifts] = shiftdata(varargin{1});
  if isa(A, 'embedded.fi')
      [Y,I] = unary_max(A);
  else
      [Y,I] = max(A);
  end
  Y = unshiftdata(Y,perm,nshifts);
  I = unshiftdata(I,perm,nshifts);
  if nargout==2
    varargout{1} = I;
  end
elseif nargin==2
  % Y = max(A,B)
  error(nargoutchk(0,1,nargout,'struct'));
  Y = binary_max(varargin{1},varargin{2});
elseif nargin==3
  % [Y,I] = max(A,[],DIM)
  if ~isempty(varargin{2})
    error('fi:max:TwoMatrixDimNotSupported',...
        'MAX with two matrices to compare and a working dimension is not supported.');
  end
  DIM = double(varargin{3}); % allow any numeric value
  if ~isscalar(DIM) || DIM<1
    error('fi:max:DimMustBePositiveIntegerScalar',...
          'Dimension argument must be a positive integer scalar.');
  end
  [A,perm,nshifts] = shiftdata(varargin{1},DIM);
  if isa(A, 'embedded.fi')
      [Y,I] = unary_max(A);
  else
      [Y,I] = max(A);
  end
  Y = unshiftdata(Y,perm,nshifts);
  I = unshiftdata(I,perm,nshifts);
  if nargout==2
    varargout{1} = I;
  end
end

function y = unshiftdata(x,perm,nshifts)
%UNSHIFTDATA  The inverse of SHIFTDATA.
%   Y = UNSHIFTDATA(X,PERM,NSHIFTS) restores the orientation of the data that
%   was shifted with SHIFTDATA.  PERM is the permutation vector, and NSHIFTS
%   is the number of shifts that were returned from SHIFTDATA.
%
%   UNSHIFTDATA is meant to be used in tandem with SHIFTDATA.  They are handy
%   for creating functions that work along a certain dimension, like MAX, MIN.
%
%   Examples:
%     x = fi(magic(3))
%     [x,perm,nshifts] = shiftdata(x,2) % Work along 2nd dimension
%     y = unshiftdata(x,perm,nshifts)   % Reshapes back to original
%
%     x = fi(1:5)                        % Originally a row
%     [x,perm,nshifts] = shiftdata(x,[]) % Work along 1st nonsingleton dimension
%     y = unshiftdata(x,perm,nshifts)    % Reshapes back to original
%
%   See also SHIFTDATA, IPERMUTE, SHIFTDIM.

% Unshiftdata is shipped with Signal.  Putting a copy here.

if isempty(perm)
  y = shiftdim(x, -nshifts);
else
  y = ipermute(x,double(perm));
end
