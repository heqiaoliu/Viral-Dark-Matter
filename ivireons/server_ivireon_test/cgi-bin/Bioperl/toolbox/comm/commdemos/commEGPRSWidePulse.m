function c0 = commEGPRSWidePulse(Nsamp)
% commEGPRSWidePulse Design a spectrally wide pulse shaping filter
%
% c0 = commEGPRSWidePulse(Nsamp) designs a spectrally wide pulse
% shaping filter for EGRPS systems as defined in [1].  Nsamp is the
% required upsampling rate and must divide 16 without a remainder.  The
% filter coefficients are returned in c0. 
%
% Reference 1: 3GPP TS 45.004 v7.2.0, GSM/EDGE Radio Access Network; Modulation,
% Release 7

%   Copyright 2008 The MathWorks, Inc.

if rem(16, Nsamp)
    error(generatemsgid('InvalidNsamp'), ...
        'Nsamp must divide 16 without a remainder');
end

delta = 16/Nsamp;

c = [...
    0.00225918460000
    0.00419757900000
    0.00648420700000
    0.00931957020000
    0.01259397500000
    0.01605878900000
    0.01959156100000
    0.02292214900000
    0.02570190500000
    0.02767928100000
    0.02852115300000
    0.02791904300000
    0.02568913000000
    0.02166792700000
    0.01579963100000
    0.00821077000000
    -0.00089211394000
    -0.01114601700000
    -0.02201830600000
    -0.03289439200000
    -0.04302811700000
    -0.05156392200000
    -0.05764086800000
    -0.06034025400000
    -0.05876224400000
    -0.05209962100000
    -0.03961692000000
    -0.02072323500000
    0.00496039200000
    0.03765364500000
    0.07732192300000
    0.12369249000000
    0.17639444000000
    0.23478700000000
    0.29768326000000
    0.36418213000000
    0.43311409000000
    0.50316152000000
    0.57298225000000
    0.64120681000000
    0.70645485000000
    0.76744762000000
    0.82295721000000
    0.87187027000000
    0.91325439000000
    0.94628290000000
    0.97030623000000
    0.98493838000000
    0.99006899000000];

c = [c; c(end-1:-1:1)];
c0 = c(1:delta:end);
% [EOF]