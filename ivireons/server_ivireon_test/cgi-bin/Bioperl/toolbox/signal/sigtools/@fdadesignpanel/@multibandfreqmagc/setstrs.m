function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:20:01 $

strs = allprops(h);
lbls = {'Freq. vector', 'Mag. vector', 'Weight vector', 'Cons. Bands'};

% [EOF]
