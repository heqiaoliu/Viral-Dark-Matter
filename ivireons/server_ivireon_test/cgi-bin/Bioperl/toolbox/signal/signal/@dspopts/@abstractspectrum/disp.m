function disp(this)
%DISP   

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:06:53 $

s = get(this);
s = reorderstructure(this,s);

if s.NormalizedFrequency,
    nfval = 'true';
else
    nfval = 'false';
end

if s.CenterDC,
    cdval = 'true';
else
    cdval = 'false';
end
s = changedisplay(s, 'NormalizedFrequency', nfval,'CenterDC', cdval);

disp(s);

% [EOF]
