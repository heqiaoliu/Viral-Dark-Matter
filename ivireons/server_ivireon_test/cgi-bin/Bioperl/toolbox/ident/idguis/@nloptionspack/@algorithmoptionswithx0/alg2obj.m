function alg2obj(this,Model)
% update the properties by reading off values from alg struct

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:04:23 $

nloptionspack.utAlg2Obj(this,Model);

%alg = Model.Algorithm;
ini = pvget(Model,'InitialState');

if isempty(ini) || strncmpi(ini,'z',1)
    this.Initial_State = 'Zero';
else
    this.Initial_State = 'Estimate';
end
