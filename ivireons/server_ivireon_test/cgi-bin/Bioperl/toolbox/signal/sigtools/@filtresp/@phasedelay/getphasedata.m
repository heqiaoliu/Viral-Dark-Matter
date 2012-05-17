function [Phi, W] = getphasedata(this)
%GETPHASEDATA Returns the phase data

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.10 $  $Date: 2007/12/14 15:17:21 $

Hd   = get(this, 'Filters');

if isempty(Hd),
    Phi = {};
    W   = {};
else
    opts = getoptions(this);

    optsstruct.showref  = showref(this.FilterUtils);
    optsstruct.showpoly = showpoly(this.FilterUtils);
    optsstruct.sosview  = this.SOSViewOpts;
    optsstruct.normalizedfreq = this.NormalizedFrequency;

    [Phi,W] = phasedelay(Hd, opts{:}, optsstruct);

end

% [EOF]
