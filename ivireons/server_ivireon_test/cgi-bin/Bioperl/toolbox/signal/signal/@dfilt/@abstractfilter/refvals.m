function v = refvals(this)
%REFVALS   Return the reference values.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:26:15 $

% Default refvals just gets the coefficients
c = coefficientnames(this);
for indx = 1:length(c)
    v{indx} = get(this, c{indx});
end

% [EOF]
