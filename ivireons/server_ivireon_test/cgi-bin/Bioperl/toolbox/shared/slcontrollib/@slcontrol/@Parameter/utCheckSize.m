function value = utCheckSize(this, value, NoTypeCheck)
% Formats the VALUE argument to be the same size as SIZES.
%
% If VALUE is a scalar, then do scalar expansion.
% If VALUE is an array, then its size should match SIZES, otherwise BADVALUE
% flag will be set to TRUE, and the original VALUE will be returned.

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/09 21:02:17 $
if nargin>2 || (isnumeric(value) && isreal(value))
  sizes = this.Dimensions;
  if isempty(sizes)
    ctrlMsgUtils.error( 'SLControllib:slcontrol:CannotSetUninitializedObject' );
  else
    % Make row vector by default
    if isscalar(value)
      value = value( ones(sizes) );
    elseif isvector(value) && length(value)==prod(sizes)
      value = reshape(value,sizes);
    elseif ~isequal( size(value), sizes );
      ctrlMsgUtils.error( 'SLControllib:slcontrol:CannotModifySize' );
    end
  end
else
  ctrlMsgUtils.error( 'SLControllib:slcontrol:RealDoubleValue' );
end
