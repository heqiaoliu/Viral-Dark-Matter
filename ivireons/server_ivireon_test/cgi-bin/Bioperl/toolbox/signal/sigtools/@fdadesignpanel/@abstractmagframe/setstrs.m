function [strs, lbls] = setstrs(h)
%SETSTRS Return the strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:39:19 $

% Get current magunits
magOpts = set(h,'magUnits');
props   = allprops(h);

switch h.magUnits,
case magOpts{1},
    strs = props(1:end/3);
case magOpts{2},
    strs = props(end/3+1:2*end/3);
case magOpts{3},
    strs = props(2*end/3+1:end);
end

lbls = cell(size(strs));
for indx = 1:length(strs)
    lbls{indx} = [strs{indx} ':'];
end

% [EOF]
