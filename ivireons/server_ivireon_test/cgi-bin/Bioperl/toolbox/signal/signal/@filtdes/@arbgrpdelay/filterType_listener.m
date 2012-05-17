function filterType_listener(h,d)
%FILTERTYPE_LISTENER Callback for type specific actions.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:10:30 $

% Set frequency vector and edges to appropriate values
set(d,'FrequencyVector',[0 4800 24000]);
set(d,'FrequencyEdges',[0 24000]);
