function g = nominalgain(this)
%NOMINALGAIN   Returns the nominal gain if an FDESIGN is present.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:17:47 $

hfdesign = getfdesign(this);

if isempty(hfdesign)
    g = [];
else
    rcf = getratechangefactors(this);
    rcf = rcf(:, 1);
    
    intfactor = prod(rcf);
    
    % If the filter was designed with FDESIGN the nominalgain should be
    % exactly equal to the overall interpolation factor.
    g = intfactor;
end

% [EOF]
