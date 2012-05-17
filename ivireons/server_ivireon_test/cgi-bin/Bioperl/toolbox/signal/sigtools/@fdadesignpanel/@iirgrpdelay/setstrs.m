function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 22:59:33 $

strs = allprops(h);
lbls = {'Freq. vector', 'Freq. Edges', 'Grpdelay vector', 'Weight vector'};

% [EOF]
