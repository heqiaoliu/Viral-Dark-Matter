function openselectdlg(h,manager)
%% manager is passed to conform to a common node api

% Copyright 2004-2005 The MathWorks, Inc.

%% Open the dialog
if ~isempty(h.Plot) && ishandle(h.Plot)
    openselectdlg(h.Plot);
end