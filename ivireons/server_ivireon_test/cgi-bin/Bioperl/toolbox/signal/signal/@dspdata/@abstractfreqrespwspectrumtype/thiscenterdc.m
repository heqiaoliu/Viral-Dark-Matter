function thiscenterdc(this)
%THISCENTERDC   Shift the zero-frequency component to center of spectrum.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:10:01 $

% First convert to a spectrum that occupies the whole Nyquist interval.
if ishalfnyqinterval(this),
    twosided(this);
end

if this.centerdc,
    % Center the DC component.
    spectrumshift(this);
else
    % Move the DC component back to the left edge.
    ispectrumshift(this);
end

% [EOF]
