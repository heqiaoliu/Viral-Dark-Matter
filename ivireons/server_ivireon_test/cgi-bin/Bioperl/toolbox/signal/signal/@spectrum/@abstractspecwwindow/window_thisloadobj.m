function window_thisloadobj(this, s)
%WINDOW_THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:23 $

set(this, 'WindowName', s.WindowName);

p = propstoaddtospectrum(this.Window);

for indx = 1:length(p)
    set(this, p{indx}, s.(p{indx}));
end

% [EOF]
