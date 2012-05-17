function setYUnits(this,Value)
% Set private yUnits member

%   Author: A. Stothert
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:57 $

if ~isa(Value,'char')
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errArgumentType','yUnits')
end
this.yUnits = Value;