function checkIsRGBVector(val)
%

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:48:54 $
if numel(val)~=3 || ~isfloat(val) || any(val<0) || any(val>1)
    % Internal message to help debugging. Not intended to be user-visible.
    errID = generatemsgid('invalidformat');
    error(errID, 'Value must be a 1x3 vector with floating-point values in the range [0,1].');
end
