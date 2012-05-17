function visible(this, vis)
%VISIBLE  Visibility of scope GUI

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/11/16 22:34:44 $

if nargin<2
    vis='on';  % turn on visibility by default
end
set(this.Parent,'vis',vis);

% Make sure that when the scope is going invisible, that all its dialogs
% are also shut off.
if strcmpi(vis, 'off')
    send(this, 'CloseDialogsEvent');
end

% [EOF]
