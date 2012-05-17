function WriteToSimulinkModel(this)
% WRITETOSIMULINKMODEL Write the parameters to the Simulink model.
%
 
% Author(s): John W. Glass 17-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 19:08:03 $
        
%% Get the tuned blocks
C = this.sisodb.loopData.C;

%% Update the block parameters
updateBlockParameters(linutil,C,this.TaskOptions);