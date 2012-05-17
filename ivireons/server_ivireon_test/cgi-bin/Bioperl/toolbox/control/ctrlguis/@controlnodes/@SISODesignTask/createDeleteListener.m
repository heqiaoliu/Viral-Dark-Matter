function createDeleteListener(this)
% CREATEDELETELISTENER 
%
 
% Author(s): John W. Glass 14-Sep-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/02/06 19:50:20 $

% Create the delete listener
this.Handles.sisodbDeleteListener = handle.listener(this.sisodb,'ObjectBeingDestroyed',...
                                 {@LocalsisodbBeingDeleted, this});
                             

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalsiodbBeingDeleted
function LocalsisodbBeingDeleted(eventSrc, eventData, this)
delete(this.Handles.sisodbDeleteListener);
% Delete the current node
parent = this.up;

if ~isempty(parent)
    parent.removeNode(this);
end