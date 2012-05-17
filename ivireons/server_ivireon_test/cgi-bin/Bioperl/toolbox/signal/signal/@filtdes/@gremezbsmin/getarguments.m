function [F, A, W, args] = getarguments(h, d)
%GETARGUMENTS Returns the design function arguments

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:07:45 $

[Fpass1, Fstop1, Fstop2, Fpass2, Dpass1, Dstop, Dpass2] = getdesignspecs(h, d);

F = [0 Fpass1 Fstop1 Fstop2 Fpass2 1];
A = [1 1 0 0 1 1];
W = [Dpass1 Dstop Dpass2];

args = {};

% [EOF]
