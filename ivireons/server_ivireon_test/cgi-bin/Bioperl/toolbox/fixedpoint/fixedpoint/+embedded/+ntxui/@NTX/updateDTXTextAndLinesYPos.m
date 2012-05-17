function updateDTXTextAndLinesYPos(ntx)
% Updates Y-position of datatype explorer text and lines

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:00 $

% Only show explorer overlay if the user requested it,
% and the system allows it:
updateDTXTextYPos(ntx);  % do before updating lines
updateDTXLinesYPos(ntx); % needs text ypos updated first
    
% Update vis of relevant text and lines
set([ntx.htWordSpan, ntx.htIntSpan, ntx.htFracSpan, ...
    ntx.htUnder, ntx.htOver, ...
    ntx.hlWordSpan, ntx.hlUnder, ntx.hlOver, ...
    ntx.hlRadixLine],'vis','on');
