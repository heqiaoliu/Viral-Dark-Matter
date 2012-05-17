function enableData(this)
%ENABLEDATA 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:34 $

send(this, 'NewData', handle.EventData(this, 'NewData'));
updateVisual(this);

% [EOF]
