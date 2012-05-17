function getsnapshotdata(this,block)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2010/05/20 03:26:01 $

% Process the Jacobian
ProcessJacobian(this,block,@LocalJacobianProcessCallback)

function LocalJacobianProcessCallback(J,var)
% Extract data leaving out io specification
this = var{2};

% Get the handle to the linearization storage;
snapshot_storage = LinearizationObjects.TimeEventStorage;

% Get the default operating point
t = J.time;
op = getopsnapshot(this,t);
model = this.ModelParameterMgr.Model;

% Post process the Jacobian data for linearization
J = postProcessJacobian(linutil,J);
% Compute the linearization
[sys,userdef_stateName,iostruct,J] = utProcessJacobian(linutil,this.ModelParameterMgr,J,this.LinData,this.iostructfcn);
% Reorder the states to match the order specified
[sys,iostruct] = utOrderNameStates(linutil,model,sys,J,userdef_stateName,iostruct,this.LinData);

% Write some notes about the linear system
sys.Notes{1} = ctrlMsgUtils.message('Slcontrol:linutil:OperatingPointTimeNote',mat2str(t));

if this.LinData.StoreJacobianData
    if isempty(snapshot_storage.Data)
        TopTreeNode = linearize.getInspectorData(this.ModelParameterMgr,model,J);
    else
        TopTreeNode = [];
    end        
    [DiagnosticMessages,BlocksInPathByName] = linearize.getDiagnosticData(J);
    InspectorData = struct('TopTreeNode',TopTreeNode,...
                        'DiagnosticMessages',DiagnosticMessages,...
                        'BlocksInPathByName',BlocksInPathByName,...
                        'J',J);
else
    InspectorData = [];
end
Data = struct('OperatingPoint',op,'sys',sys,...
                    'InspectorData',InspectorData,'iostruct',iostruct);
snapshot_storage.Data = [snapshot_storage.Data;Data];
