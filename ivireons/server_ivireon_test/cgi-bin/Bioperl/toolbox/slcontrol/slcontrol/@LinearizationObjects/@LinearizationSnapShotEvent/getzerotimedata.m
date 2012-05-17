function Data = getzerotimedata(this)
% GETZEROTIMEDATA  Method to gather snapshots

% Author(s): John Glass
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6.2.1 $ $Date: 2010/07/06 14:42:19 $

% Get the zero operating point
op = getopsnapshot(this,0);
model = this.ModelParameterMgr.Model;

% Get the Jacobian data structure
this.ModelParameterMgr.compile('lincompile');
utPushOperatingPoint(linutil,model,op,this.LinData.opt);
J_iter = getJacobian(linutil,model,this.IOSpec);

% Evaluate the Jacobian
[sys,userdef_stateName,iostruct,J] = ...
    utProcessJacobian(linutil,this.ModelParameterMgr,J_iter,this.LinData,this.iostructfcn);

% Reorder the states to match the order specified
if isempty(this.LinData.StateOrder)
    [sys, iostruct] = utOrderNameStates(linutil,model,sys,J,userdef_stateName,iostruct,this.LinData);
end

if this.LinData.StoreJacobianData
    TopTreeNode = linearize.getInspectorData(this.ModelParameterMgr,model,J);
    [DiagnosticMessages,BlocksInPathByName] = linearize.getDiagnosticData(J);
    InspectorData = struct('TopTreeNode',TopTreeNode,...
        'DiagnosticMessages',DiagnosticMessages,...
        'BlocksInPathByName',BlocksInPathByName,...
        'J',J);
else
    InspectorData = [];
end

this.ModelParameterMgr.term;
sys.Notes{1} = ctrlMsgUtils.message('Slcontrol:linutil:OperatingPointTimeNote','0');
Data = struct('OperatingPoint',op,'sys',sys,...
                    'InspectorData',InspectorData,'iostruct',iostruct);
