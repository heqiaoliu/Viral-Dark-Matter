function createDeleteListener(this)
% CREATEDELETELISTENER  Enter a description here!
%
 
% Author(s): John W. Glass 14-Sep-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 19:08:05 $

%% Create the delete listener
this.Handles.DeleteListener = handle.listener(this,'ObjectBeingDestroyed',...
                                 {@LocalNodeBeingDeleted, this});
                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalViewBeingDeleted
function LocalNodeBeingDeleted(es,ed,this)

%% Delete the sisoview if needed
if ishandle(this.sisodb)
    close(this.sisodb);
end