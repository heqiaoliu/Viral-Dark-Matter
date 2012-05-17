function R=covf(ze,M,maxsize)
%COVF  Computes the covariance function estimate for a data matrix.
%   R = COVF(DATA,M)
%
%   DATA : An IDDATA data object. See Help IDDATA.
%
%   M: The maximum delay - 1, for which the covariance function is estimated.
%   Z is the output-input data: Z = [Data.OutputData, Data.InputData].
%   R: The covariance function of Z, returned so that the entry
%   R((i+(j-1)*nz,k+1) is  the estimate of E Zi(t) * Zj(t+k)
%   The size of R is thus nz^2 x M (nz = size(Z,2))
%   For complex data z, RESHAPE(R(:,k+1),nz,nz) = E z(t)*z'(t+k)
%   (z' is complex conjugate, transpose)
%
%   For nz<=2, an FFT algorithm is used, memory size permitting.
%   For nz>2,  straightforward summation is used (in COVF2)
%
%   The memory trade-off is affected by
%   R = COVF(Z,M,maxsize)
%   See also IDPROPS ALGORITHM for how to use this option.

%   L. Ljung 10-1-86,11-11-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.8 $  $Date: 2009/11/09 16:23:31 $

error(nargchk(2,3,nargin,'struct'))

if strcmpi(ze.Domain,'Frequency')
    ctrlMsgUtils.error('Ident:dataprocess:covfFreqData')
end

%[Ncap,nz]=size(z);
Ncaps = size(ze,'N');
Ne = length(Ncaps);
nz = size(ze.InputData{1},2)+size(ze.OutputData{1},2);
maxsdef = idmsize(max(Ncaps));
if nargin<3, maxsize = maxsdef; end
if isempty(maxsize), maxsize = maxsdef; end

if nz>2  ||  max(Ncaps)>maxsize/8 || ~isreal(ze) || min(Ncaps)<=M
    R = covf2(ze,M);
    return
end

R = zeros(nz*nz,M);
sumncap = 0;
for kexp = 1:Ne
    z = [ze.OutputData{kexp},ze.InputData{kexp}];
    [Ncap,nz] = size(z);
    nfft = 2.^ceil(log(2*Ncap)/log(2));
    Ycap = fft(([z(:,1)' zeros(1,Ncap)]),nfft);
    if nz==2
        Ucap = fft(([z(:,2)'  zeros(1,Ncap)]),nfft);
        YUcap = Ycap.*conj(Ucap);
        UAcap = abs(Ucap).^2;
        clear Ucap
    end
    YAcap = abs(Ycap).^2;
    clear Ycap
    RYcap = fft(YAcap,nfft);
    n = length(RYcap);
    sumncap = sumncap+Ncap;
    R1 = real(RYcap(1:M))/n;
    clear RYcap
    if nz>1
        RUcap = fft(UAcap,nfft);
        ru = real(RUcap(1:M))/n;
        clear RUcap
        RYUcap = fft(YUcap,nfft);
        ryu = real(RYUcap(1:M))/n;
        ruy = real(RYUcap(n:-1:n-M+2))/n;
        clear RYUcap
        R1 = [R1;[ryu(1) ruy];ryu;ru];
    end
    R = R + R1;
end
R = R/sumncap;

% -------------------------------------------------------------------------
function R = covf2(ze,M)
%COVF2   Computes covariance function estimates

Ne = length(ze.OutputData);
nz = size(ze.InputData{1},2)+size(ze.OutputData{1},2);
R = zeros(nz*nz,M);
Ncap = 0;
for kexp = 1:Ne
    z = [ze.OutputData{kexp},ze.InputData{kexp}];
    [N,nz] = size(z);
    z = [z;zeros(M,nz)];
    j = 1:N;
    for k = 1:M
        a = z(j,:)'*z(j+k-1,:);
        R(:,k) = R(:,k)+conj(a(:));
    end
    Ncap = Ncap + N;
end
R = R/Ncap;
