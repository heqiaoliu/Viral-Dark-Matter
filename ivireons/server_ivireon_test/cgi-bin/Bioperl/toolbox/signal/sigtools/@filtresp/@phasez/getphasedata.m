function [Phi, W] = getphasedata(this)
%GETPHASEDATA Returns the phase data

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.5 $  $Date: 2004/12/26 22:18:59 $

Hd   = get(this, 'Filters');
opts = getoptions(this);

if isempty(Hd),
    Phi = {};
    W   = {};
else
        
    optsstruct.showref  = showref(this.FilterUtils);
    optsstruct.showpoly = showpoly(this.FilterUtils);
    optsstruct.sosview  = get(this, 'SOSViewOpts');
    
    if strcmpi(get(this, 'PhaseDisplay'), 'Phase'),
        [Phi,W] = phasez(Hd, opts{:}, optsstruct);
    else,
        [H,W,Phi] = zerophase(Hd, opts{:}, optsstruct);
    end
end

% [EOF]
