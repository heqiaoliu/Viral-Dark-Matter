function [F, A, W, args] = getarguments(h, d)
%GETARGUMENTS Return the design method arguments

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:06:00 $

F = [0 get(d, 'Fstop') get(d, 'Fpass') 1];
A = [0 0 1 1];

mu = get(d, 'magUnits'); set(d, 'magUnits', 'linear');
W = [get(d, 'Dstop') 1]; set(d, 'magUnits', mu);

args = {};

% [EOF]
