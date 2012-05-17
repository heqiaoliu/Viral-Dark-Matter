function utRestoreTunedMask(this,TunedMask)
% Restores TunedMask from a TunedMaskSnapshot

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:46:25 $
  
TunedMask.Name = this.Name;

TunedMask.Ts = this.Value.Ts;

TunedMask.TsOrig = this.TsOrig;

TunedMask.Par2ZPKFcn = this.Par2ZPKFcn;

TunedMask.AuxData = this.AuxData;
TunedMask.D2CMethod = this.D2CMethod;
TunedMask.C2DMethod = this.C2DMethod;

TunedMask.Parameters = this.Parameters;
TunedMask.updateZPK;




