function mnk = inpd2nk(md)
%INPD2NK converts input delays to state space models with explicit delays
%
%   Modnk = INPD2NK(Mod)
%
%   Mod: any discrete time IDMODEL with specified Property InputDelay.
%   Modnk: A discrete time IDSS model in free parameterization with the
%      the input delays represented in the A, B, C - matrices. Thus
%      Modnk.InputDelay = 0, but Modnk.nk not zero.

%   L. Ljung 02-01-03
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2008/10/02 18:51:39 $

if pvget(md,'Ts')==0
    ctrlMsgUtils.error('Ident:transformation:inpd2nk')
end
mnk = idss(md);
mnk = pvset(mnk,'SSParameterization','Free');
inpd = pvget(mnk,'InputDelay');
nk = pvget(mnk,'nk');
nk = max(nk,1);
mnk = pvset(mnk,'InputDelay',zeros(size(inpd)));
mnk = pvset(mnk,'nk',nk+inpd');
