function createDefaultListeners(this)
% CREATEDEFAULTLISTENERS  Create the default listeners.
%
 
% Author(s): John W. Glass 17-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/02/17 19:07:52 $

% Create a listener to loopdata for loopdata changed events.  This
% callback will update the parameters of the Simulink model.
LoopData = this.sisodb.LoopData;
this.AutoUpdateListener = handle.listener(LoopData,'LoopDataChanged',...
                            {@LocalWriteToModel, this});
this.AutoUpdateListener.Enabled = this.AutoUpdateEnabled;

% Create the delete listener
this.Handles.DeleteListener = handle.listener(this,'ObjectBeingDestroyed',...
                                 {@LocalNodeBeingDeleted, this});

%%
function LocalWriteToModel(es,ed,this)                             
try
    WriteToSimulinkModel(this) 
catch Ex
    errordlg(ltipack.utStripErrorHeader(Ex.message),'Simulink Control Design');
    return
end                             
                             
%%
function LocalNodeBeingDeleted(es,ed,this)

% Delete the sisoview if needed
if ishandle(this.sisodb)
    close(this.sisodb);
end