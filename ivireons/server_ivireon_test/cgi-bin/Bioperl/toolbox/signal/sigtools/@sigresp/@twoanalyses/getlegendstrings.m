function strs = getlegendstrings(hObj, varargin)
%GETLEGENDSTRINGS Returns the legend strings

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:12 $

resps = get(hObj, 'Analyses');

strs1 = getlegendstrings(resps(1), legendstring(resps(1)));
strs2 = getlegendstrings(resps(2), legendstring(resps(2)));

strs = {strs1{:}, strs2{:}};

% [EOF]
