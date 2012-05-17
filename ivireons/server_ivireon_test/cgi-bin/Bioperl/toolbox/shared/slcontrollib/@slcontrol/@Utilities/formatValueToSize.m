function value = formatValueToSize(this, value, sizes, NoTypeCheck)
% FORMATVALUETOSIZE Formats the VALUE argument to be the same size as SIZES.
%
% SIZES   A row vector of dimension lengths
%
% VALUE - empty : reshape to SIZES only if at least one element of SIZES is zero.
%       - scalar: do scalar expansion.
%       - vector: reshape it to match SIZES.
%       - array : its size should match SIZES.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/11/09 21:02:32 $

% Convert to double if type checking
if (nargin <= 3)
  try
    value = double(value);
  catch
    ctrlMsgUtils.error( 'SLControllib:slcontrol:CannotConvertToDouble' );
  end
end

if (nargin > 3) || ( isnumeric(value) && isreal(value) )
  % Adjust value to appropriate size
  if ~isempty(sizes)
    if isscalar(value)
      % Scalar expansion
      value = value( ones(sizes) );
    elseif isvector(value) && length(value) == prod(sizes)
      % Vector with same number of elements.
      value = reshape(value, sizes);
    elseif prod(size(value)) == prod(sizes)
      % Array with same number of elements. Includes size(value) == sizes.
      value = reshape(value, sizes);
    else
      ctrlMsgUtils.error( 'SLControllib:slcontrol:CannotModifySize' );
    end
  else
    ctrlMsgUtils.error( 'SLControllib:slcontrol:CannotSetUninitializedObject' );
  end
else
  ctrlMsgUtils.error( 'SLControllib:slcontrol:RealDoubleValue' );
end
