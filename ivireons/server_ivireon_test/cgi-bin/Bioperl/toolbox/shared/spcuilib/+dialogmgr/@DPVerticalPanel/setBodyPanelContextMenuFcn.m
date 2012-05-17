function setBodyPanelContextMenuFcn(dp,contextMenuFcn)
% Register an optional context menu creation function for the Body panel.
% If registered, function is called whenever a right-click on the Body
% panel occurs.
%
% The function must take hParent and hContext as its only arguments.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:01 $

if ~isa(contextMenuFcn,'function_handle')
    % Internal message to help debugging. Not intended to be user-visible.
    errID = generatemessageid('invalidformat');
    error(errID, 'Context menu function must be of type function_handle');
end

dp.BodyContextMenuHandler = contextMenuFcn;
