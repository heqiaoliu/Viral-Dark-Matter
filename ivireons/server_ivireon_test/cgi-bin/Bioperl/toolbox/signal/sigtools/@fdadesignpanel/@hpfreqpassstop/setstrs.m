function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 22:59:06 $

strs = {'Fstop','Fpass'};
lbls = {[fvw(h) 'stop:'], [fvw(h) 'pass:']};

% [EOF]
