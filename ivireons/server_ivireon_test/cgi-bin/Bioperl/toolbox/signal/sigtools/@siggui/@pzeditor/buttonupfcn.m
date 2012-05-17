function buttonupfcn(this)
%BUTTONUPFCN Function that is called when the button is released

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2005/06/16 08:46:20 $

if ~strcmpi(get(this, 'ButtonClickType'), 'Left'), return; end

% Make sure the limits are updated.
updatelimits(this);

send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% [EOF]
