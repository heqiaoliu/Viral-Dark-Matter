function [F, A] = getmask(this, fcns, rcf, specs)
%GETMASK   Get the mask.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:23:00 $

if nargin < 4 || isempty(specs)
    specs = getspecs(this);
end

F = [specs.Fstop1 specs.Fstop1 0 0 specs.Fpass1 specs.Fpass1 ...
    specs.Fpass2 specs.Fpass2 1 1 specs.Fstop2 specs.Fstop2 specs.Fstop1]*fcns.getfs()/2;

% Format the apass for dB/linear and constrained
apass1 = fcns.formatapass(specs.Apass1);
apass2 = fcns.formatapass(specs.Apass2);

astop = fcns.formatastop(specs.Astop);

A = [astop(3) apass1(2) apass1(2) apass1(1) apass1(1) astop(2) ...
    astop(2) apass2(1) apass2(1) apass2(2) apass2(2) astop(3) astop(4)];

% [EOF]
