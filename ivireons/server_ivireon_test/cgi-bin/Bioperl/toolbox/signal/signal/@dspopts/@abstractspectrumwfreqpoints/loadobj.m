function this = loadobj(s)
%LOADOBJ  Load this object.
%   OUT = LOADOBJ(ARGS) <long description>

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:44:53 $

this = feval(s.class);

% Set FreqPoints first
set(this, 'FreqPoints', s.FreqPoints);

f = fieldnames(get(this));
indx = strmatch('FreqPoints',f);
f(indx) = [];

for indx = 1:length(f)
    set(this, f{indx}, s.(f{indx}));
end


% [EOF]
