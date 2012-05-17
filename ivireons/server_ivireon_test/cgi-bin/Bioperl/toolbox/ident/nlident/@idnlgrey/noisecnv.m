function sys = noisecnv(nlsys, option)
%NOISECNV  Converts noise channels to measured channels.
%
%   SYS = NOISECNV(NLSYS, Noise)
%
%   NLSYS is an IDNLGREY model with no inputs.
%   SYS is an IDSS model which describes the (trivial) model y = e, where e
%   is the noise source of NLSYS.
%
%   There are two variants. If Noise = 'N(ormalize)', the noise sources are
%   first normalized to be independent and of unit variance. If Noise =
%   'I(nnovation)' no normalization takes place, and the noise sources
%   remain as the innovations process.
%
%   The input channels e are given InputNames 'e@yk', where 'yk' is the
%   OutputName of the k:th channel. This gives the "e-contribution at the
%   k:th output channel."  In the normalized case, the input channels are
%   given the names 'v@yk' instead.
%
%   The function is primarily a help function to STEP when applied to
%   a time series IDNLGREY model.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:53:54 $

% Check that the function is called with 1 or 2 input arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Only possible for time series!
if (size(nlsys, 'nu') > 0)
    ctrlMsgUtils.error('Ident:transformation:idnlgreyNoiseConvNotPossible')
end

% Basic error checking.
if (nin < 2)
    option = 'i';
end
option = lower(option(1));
if ~((option == 'n') || (option == 'i'))
    ctrlMsgUtils.error('Ident:transformation:noisecnvCheck1')
end

ny = size(nlsys, 'ny');
if (option == 'n')
    L = chol(pvget(nlsys, 'NoiseVariance')).';
    pref = 'v';
else
    L = eye(ny);
    pref = 'e';
end
ynam = pvget(nlsys, 'OutputName');

sys = idss([], [], [], L, zeros(0, ny), 'noi', zeros(ny, ny));
sys = pvset(sys, 'OutputName', ynam);
for kk = 1:ny
    unam{kk} = [noiprefi(pref) ynam{kk}];
end
sys = pvset(sys, 'InputName', unam);
