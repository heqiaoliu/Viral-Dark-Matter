function disp(this)
%DISP   Display method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:00:21 $

proplist = reorderprops(this);
snew = reorderstructure(get(this),proplist{:});

val = 'false';
if this.NormalizedFrequency,
    val = 'true';
end
snew.NormalizedFrequency = val;
snew = changedisplay(snew,'NormalizedFrequency',val);
disp(snew);

% [EOF]
