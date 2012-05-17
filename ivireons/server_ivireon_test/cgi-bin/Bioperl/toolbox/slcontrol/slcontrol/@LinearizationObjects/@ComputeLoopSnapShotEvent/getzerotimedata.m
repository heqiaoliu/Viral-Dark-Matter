function Data = getzerotimedata(this)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/05/20 03:25:57 $

% Get the zero operating point
op = getopsnapshot(this,0);

% Compute the loop data
mdl = this.ModelParameterMgr.Model;
this.ModelParameterMgr.compile('lincompile');
try
    % Push the operating point onto the model
    utPushOperatingPoint(linutil,mdl,op,this.linopts);
    J = getJacobian(linutil,mdl,this.IOSpec);
    loopdata = utJacobian2LoopData(linutil,this.ModelParameterMgr,J,...
        this.IOSettings,this.TunedBlocks,this.linopts);
    Data = struct('OperatingPoint',op,'loopdata',loopdata);
catch Ex
    this.ModelParameterMgr.term;
    rethrow(Ex)
end
this.ModelParameterMgr.term;
