function createvaluefromcell(hPrm)
%CREATEVALUEFROMCELL Create the value property from a cell array

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/11/21 15:33:32 $

% This must be a private method
% This has been moved outside of parameter so it can be called from setvalidvalues

valid    = get(hPrm, 'AllOptions');
typename = getuniquetype(hPrm, valid);

schema.prop(hPrm, 'Value', typename);

% [EOF]
