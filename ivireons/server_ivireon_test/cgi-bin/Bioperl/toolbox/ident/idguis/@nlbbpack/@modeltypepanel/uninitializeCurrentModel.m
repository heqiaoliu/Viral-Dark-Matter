function uninitializeCurrentModel(this,Type)
%Reset the parameter values and estimation status of nonlinear models.
% Type: 'idnlarx' or 'idnlhw'

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:12:41 $

if nargin<2
    Type = this.getCurrentModelTypeID;
end

this.getPanelForType(Type).uninitializeCurrentModel;
