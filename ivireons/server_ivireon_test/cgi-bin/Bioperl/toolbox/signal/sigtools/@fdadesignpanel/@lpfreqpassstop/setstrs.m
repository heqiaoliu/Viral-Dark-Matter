function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:00:20 $

strs = {'Fpass','Fstop'};
lbls = {[fvw(h) 'pass:'], [fvw(h) 'stop:']};
    
% [EOF]
