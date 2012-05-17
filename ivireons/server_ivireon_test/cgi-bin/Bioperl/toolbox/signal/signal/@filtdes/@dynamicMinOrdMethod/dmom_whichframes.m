function fr = dmom_whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:36:04 $

% Call super's method
fr = super_whichframes(h);

% Change isMinOrd in filter order frame
indx = find(strcmpi({fr.constructor},'siggui.filterorder'));
if isdynpropenab(h,'orderMode');
    fr(indx).setops  = {'isMinOrd',1};
end
