function [oppoint,opreport] = computeresults(this,xstruct,u)
% COMPUTERESULTS

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/10/15 23:31:30 $

% Construct the operating condition object
oppoint = CreateOpPoint(this.opcond);

% Set the data
oppoint = setxu(oppoint,xstruct,u);

% Compute with the output constraint deviations
y = getOutputs(this.opcond,xstruct,u);

% Compute the derivatives and the update deviations
dxstruct = getDerivs(slcontrol.Utilities,this.model,this.t,xstruct,u);

% Compute the operating condition report
opreport = CreateOpReport(this.opcond);

% Set the data
setxuydx(opreport,xstruct,u,y,dxstruct)
