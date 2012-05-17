function setDimensions(this, value)
% SETDIMENSIONS Sets the dimensions of the port identified by THIS.
%
% DIMS equals
%   1 for a scalar signal,
%   n for a vector signal of size n,
%   [m,n] for a matrix-valued signal of size [m,n].
%
% NOTE: A vector signal of size n is not the same as matrix-valued signals of
% size [n,1] or [1,n].

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:21 $

% Formats the dimensions and checks if it has a valid value.
if isnumeric(value) && isreal(value) && isvector(value) && (length(value) <= 2)
  % Always make it a row vector.
  value = value(:)';
else
  ctrlMsgUtils.error( 'SLControllib:slcontrol:IntegerVectorValue', 'Dimensions' );
end

this.Dimensions = value;

% Reset aliases
setAliases(this);
