function thiscenterdc(this)
%THISCENTERDC   Shift the zero-frequency component to center of spectrum.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:06:12 $

% First convert to a spectrum that occupies the whole Nyquist interval.
if ishalfnyqinterval(this),
    wholerange(this);
end

if this.centerdc,
    % Center the DC component.
    spectrumshift(this);
else
    % Move the DC component back to the left edge.
    ispectrumshift(this);
end

% [EOF]
