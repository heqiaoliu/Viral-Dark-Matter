function ProcessJacobian(this,block,fcn)
% GETJACOBIAN  Method to get and process Jacobian data from a Simulink model. 
 
% Author(s): John W. Glass 23-May-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/20 03:26:02 $

% If the block is in the top model use the RequestLinearization callback
if strcmp(this.ModelParameterMgr.Model,getfullname(bdroot(block.BlockHandle)))
    block.RequestLinearization(fcn,{this.IOSpec, this});
else
    % If the block is in a model reference get the Jacobian directly
    J = feval(this.ModelParameterMgr.Model,this.IOSpec,[],[],'graph_jacobian');
    feval(fcn,J,{this.IOSpec, this});
end
