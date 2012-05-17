function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:19:47 $

strs = allprops(h);
lbls = {xlate('Freq. vector'), xlate('Mag. vector'), xlate('Weight vector')};

% [EOF]
