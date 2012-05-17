function wf = whichframes(h)
%WHICHFRAMES

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:20:55 $

wf = anom_whichframes(h);

indx = find(strcmpi({wf.constructor}, 'siggui.textOptionsFrame'));

if isempty(indx), indx = length(wf)+1; end

wf(indx).constructor = 'siggui.ifiroptsframe';
wf(indx).setops      = {};

% [EOF]
