function sendfiltrespwarnings(this)
%SENDFILTRESPWARNINGS   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:21:34 $

frw = get(this, 'FiltRespWarnings');
for indx = 1:length(frw),
    notification_listener(this, frw(indx), true);
end
set(this, 'FiltRespWarnings', []);

% [EOF]
