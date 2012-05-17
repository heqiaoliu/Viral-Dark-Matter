function this = utStoreTunedZPK(this,TunedZPK);
% stores TunedZPK into a TunedZPKSnapshot

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 17:39:49 $


this.Name = TunedZPK.Name;
this.Variable = TunedZPK.Variable;

this.Ts = TunedZPK.Ts;
this.TsOrig = TunedZPK.TsOrig;

this.Parameters = TunedZPK.Parameters;
this.Par2ZPKFcn = TunedZPK.Par2ZPKFcn;
this.ZPK2ParFcn = TunedZPK.ZPK2ParFcn;
this.Constraints = TunedZPK.Constraints;
this.FixedDynamics = TunedZPK.FixedDynamics;

this.AuxData = TunedZPK.AuxData;
this.C2DMethod = TunedZPK.C2DMethod;
this.D2CMethod = TunedZPK.D2CMethod;

% Store PZGroups as struct
PZGroup = repmat(struct('Type','','Zero',[],'Pole',[]),[0,1]);

for ct = length(TunedZPK.PZGroup):-1:1
    PZGroup(ct) = getTypeZeroPole(TunedZPK.PZGroup(ct));
end

this.PZGroup = PZGroup;

this.ZPKGain = getZPKGain(TunedZPK);

InitValue =  zpk(TunedZPK);
this.Value = zpk(InitValue.z,InitValue.p,InitValue.k,TunedZPK.Ts);
this.InitialValue = InitValue ;



