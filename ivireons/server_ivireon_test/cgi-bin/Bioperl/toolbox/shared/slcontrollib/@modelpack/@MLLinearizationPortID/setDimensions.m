function setDimensions(this, value)
% SETDIMENSIONS Sets the dimensions of the linearization port identified by
% THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:59:42 $

% Formats the dimensions and checks if it has a valid value.
if isnumeric(value) && isreal(value) && isvector(value) && (length(value) <= 2)
  % Always make it a row vector.
  value = reshape( value, [1 numel(value)] );
else
  ctrlMsgUtils.error( 'SLControllib:slcontrol:IntegerVectorValue', 'Dimensions' );
end

this.Dimensions = value;

% Reset aliases
setAliases(this);
