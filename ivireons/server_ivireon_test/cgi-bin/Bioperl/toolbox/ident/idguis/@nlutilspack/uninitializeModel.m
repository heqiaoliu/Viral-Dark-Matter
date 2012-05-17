function newmodel = uninitializeModel(model)
%Reset the parameter values and estimation status of nonlinear models.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:30 $

newmodel = pvset(model,'Estimated',0);

if isa(model,'idnlarx')
    newmodel.Nonlinearity = initreset(newmodel.Nonlinearity);
elseif isa(model,'idnlhw')
    newmodel.InputNonlinearity = initreset(newmodel.InputNonlinearity);
    newmodel.OutputNonlinearity = initreset(newmodel.OutputNonlinearity);
end
