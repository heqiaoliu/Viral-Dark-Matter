function changeDTXFracSpanText(ntx,hThisMenu)
% Change fraction span text display option
% 1 = Fraction length
% 2 = Scale factor

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:56 $

% Get selected value from userdata of context menu
ntx.DTXFracSpanText = get(hThisMenu,'userdata');
initHistDisplay(ntx);
