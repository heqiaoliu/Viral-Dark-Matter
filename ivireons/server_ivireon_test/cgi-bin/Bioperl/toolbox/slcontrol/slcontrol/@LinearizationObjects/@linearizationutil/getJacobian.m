function J = getJacobian(this,model,iospec)
% getJacobian Get the Jacobian from the model and perform any needed post 
% processing. 

%  Author(s): John Glass
%  Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/05/20 03:26:07 $

% Get the Jacobian from the model
J = postProcessJacobian(this,feval(model,iospec,[],[],'graph_jacobian'));

