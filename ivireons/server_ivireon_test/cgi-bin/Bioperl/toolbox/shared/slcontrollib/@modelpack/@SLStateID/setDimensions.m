function setDimensions(this, value)
% SETDIMENSIONS Sets the dimensions of the state identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:24 $

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
