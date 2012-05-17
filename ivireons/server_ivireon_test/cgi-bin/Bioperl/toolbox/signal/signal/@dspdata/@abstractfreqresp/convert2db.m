function HdB = convert2db(this,H)
%CONVERT2DB   Convert input response to db values.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:00:19 $

ws = warning; % Cache warning state
warning off   % Avoid "Log of zero" warnings
HdB = db(H,'voltage');  % Call the Convert to decibels engine
warning(ws);  % Reset warning state

% [EOF]
