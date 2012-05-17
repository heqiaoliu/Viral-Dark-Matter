function value = utFormatValueToSize(value, sizes)
% UTFORMATVALUETOSIZE Formats the VALUE array to the size SIZES.
%
% SIZES  A row/column vector of sizes (dimensions).
%
% VALUE  empty : reshape to SIZES only if at least one element of SIZES is zero.
%        scalar: do scalar expansion.
%        vector: reshape it to match SIZES.
%        array : its size should be consistent with SIZES.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/11/09 20:59:38 $

% Value must be a numeric or logical array.
if isnumeric(value) || islogical(value)
  % Check if sizes is a valid vector of dimensions.
  if ~isempty(sizes) && isnumeric(sizes) && isvector(sizes) && isreal(sizes)
    % Make sizes a row vector of length 2 or more.
    sizes = reshape(sizes, 1, []);
    if length(sizes) < 2
      sizes = [sizes, 1];
    end

    % Adjust size of value to match sizes.
    if isscalar(value)
      % Scalar expansion.
      value = value( ones(sizes) );
    elseif isvector(value) && length(value) == prod(sizes)
      % Vector with same number of elements.
      value = reshape(value, sizes);
    elseif prod(size(value)) == prod(sizes)
      % Array with same number of elements.  Includes size(value) == sizes.
      value = reshape(value, sizes);
    else
      ctrlMsgUtils.error( 'SLControllib:modelpack:SizeMismatch' );
    end
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:IntegerVectorArgument', ...
                        'SIZES' );
  end
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:NumericArrayArgument', ...
                      'VALUE' );
end
