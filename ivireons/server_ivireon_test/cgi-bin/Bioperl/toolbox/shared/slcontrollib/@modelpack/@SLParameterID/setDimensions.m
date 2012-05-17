function setDimensions(this, value)
% SETDIMENSIONS Sets the dimensions of the parameter identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:17 $

% Formats the dimensions and checks if it has a valid value.
if isnumeric(value) && isreal(value) && isvector(value)
  % Always make it a row vector.
  value = value(:)';
else
  ctrlMsgUtils.error( 'SLControllib:slcontrol:IntegerVectorValue', 'Dimensions' );
end

this.Dimensions = value;
