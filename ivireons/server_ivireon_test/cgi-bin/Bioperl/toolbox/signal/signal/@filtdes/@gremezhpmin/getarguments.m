function [F, A, W, args] = getarguments(h, d)
%GETARGUMENTS Return the arguments for the design function

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:08:05 $

[Fstop, Fpass, Dstop, Dpass] = getdesignspecs(h, d);

F = [0 Fstop Fpass 1];
A = [0 0 1 1];
W = [Dstop Dpass];

args = {};

% [EOF]
