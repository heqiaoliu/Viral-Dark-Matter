function close(this)
%CLOSE   Callback that is fired when the dialog is closed.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:27:35 $

% hfvt = get(this, 'FVTool');
% 
% % If FVTool is still open when the dialog is being closed, it needs to be
% % closed as well.
% if ~isempty(hfvt) && isa(hfvt, 'sigtools.fvtool')
%     close(hfvt);
% end

% [EOF]
