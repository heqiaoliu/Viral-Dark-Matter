function utRestoreTunedZPK(this,TunedZPK)
% Restores TunedZPK from a TunedZPKSnapshot

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2006/06/20 20:01:14 $


if isempty(this.Value)
    this.Value = 1;
end

zpkValue = getPrivateData(zpk(this.Value));
    
TunedZPK.Name = this.Name;
TunedZPK.Variable = this.Variable;

TunedZPK.Ts = zpkValue.Ts;

TunedZPK.TsOrig = this.TsOrig;

TunedZPK.Par2ZPKFcn = this.Par2ZPKFcn;
TunedZPK.ZPK2ParFcn = this.ZPK2ParFcn;
TunedZPK.Constraints = this.Constraints;

TunedZPK.AuxData = this.AuxData;
TunedZPK.D2CMethod = this.D2CMethod;
TunedZPK.C2DMethod = this.C2DMethod;

if isequal(zpkValue,this.InitialValue) && isTunable(TunedZPK)
    % Store PZGroups as struct
    PZGroup = handle(zeros(0,1));
    for ct = length(this.PZGroup):-1:1
        PZGroup(ct) = sisodata.(['PZGroup',this.PZGroup(ct).Type])(TunedZPK);
        set(PZGroup(ct),'Zero', this.PZGroup(ct).Zero(:),'Pole',this.PZGroup(ct).Pole(:))
    end
    TunedZPK.PZGroup = PZGroup;
    TunedZPK.FixedDynamics = this.FixedDynamics;
    TunedZPK.setZPKGain(this.ZPKGain);
    TunedZPK.Parameters = this.Parameters;
    TunedZPK.updateParams;

else
    if isTunable(TunedZPK)
        TunedZPK.Parameters = this.Parameters;
        % Since the parameters are the truth in this case clear out the
        % fixed dynamics.
        if ~isempty(TunedZPK.FixedDynamics)
            TunedZPK.FixedDynamics = ltipack.zpkdata({zeros(0,1)},{zeros(0,1)},1,TunedZPK.Ts);
        end

        TunedZPK.updatePZGroups(zpkValue);
        TunedZPK.setZPKGain(zpkValue.k);
        TunedZPK.updateParams;
        %% Update the zpk data since the parameter update may change the
        %% number of fixed elements.
        TunedZPK.updateZPK;
    else
        TunedZPK.Parameters = this.Parameters;
        TunedZPK.updateZPK;
    end
end

TunedZPK.addListeners;


