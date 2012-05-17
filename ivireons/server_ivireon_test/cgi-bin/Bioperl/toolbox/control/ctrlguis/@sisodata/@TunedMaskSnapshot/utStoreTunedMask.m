function this = utStoreTunedMask(this,TunedMask);
% stores TunedMask into a TunedMaskSnapshot

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:46:26 $


this.Name = TunedMask.Name;

this.Ts = TunedMask.Ts;
this.TsOrig = TunedMask.TsOrig;

this.Parameters = TunedMask.Parameters;
this.Par2ZPKFcn = TunedMask.Par2ZPKFcn;

this.AuxData = TunedMask.AuxData;
this.C2DMethod = TunedMask.C2DMethod;
this.D2CMethod = TunedMask.D2CMethod;




