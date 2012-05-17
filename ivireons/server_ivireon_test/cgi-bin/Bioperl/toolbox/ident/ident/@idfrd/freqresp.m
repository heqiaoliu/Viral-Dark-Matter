function [fr1,w,covff] = freqresp(sys,wdes)
%IDFRD/FREQRESP Frequency response of IDFRD models.
%
%   H = FREQRESP(M) computes the frequency response H of the
%   IDFRD model M at the frequencies specified by M.Frequency.
%
%   If M has NY outputs and NU inputs, and W contains NW frequencies,
%   the output H is a NY-by-NU-by-NW array such that H(:,:,k) gives
%   the response at the frequency W(k).
%
%   For a SISO model, use SQUEEZE(H) (See HELP SQUEEZE) to obtain a
%   vector of the frequency response.
%
%   [H,W] = FREQRESP(M,WDES) returns the values in the frequency span from
%   min(WDES) to max(WDES). The unit of W and WDES is always rad/s
%   regardless of M.UNITS. Note that no interpolation is performed if
%   values in WDES do not coincide with those in M.Frequency. W is a subset
%   of M.Frequency in the min(WDES) to max(WDES) range. It is best to
%   specify WDES as a 2-element vector: [Wmin,Wmax].
%
%   [H,W,covH] = FREQRESP(M) also returns the frequencies W and the
%   covariance covH of the response. Moreover, covH is a 5D-array where
%   covH(KY,KU,k,:,:)) is the 2-by-2 covariance matrix of the response
%   from input KU to output KY at frequency  W(k). The 1,1 element
%   is the variance of the real part, the 2,2 element the variance
%   of the imaginary part and the 1,2 and 2,1 elements the covariance
%   between the real and imaginary parts. SQUEEZE(covH(KY,KU,k,:,:))
%   gives the covariance matrix of the corresponding response.
%
%   If M is a time series (no input), H is returned as the (power)
%   spectrum of the outputs; an NY-by-NY-by-NW array. Hence H(:,:,k)
%   is the spectrum matrix at frequency W(k). The element H(K1,K2,k) is
%   the cross spectrum between outputs K1 and K2 at frequency W(k).
%   When K1=K2, this is the real-valued power spectrum of output K1.
%   covH is then the covariance of the spectrum H, so that covH(K1,K1,k) is
%   the variance of the power spectrum out output K1 at frequnecy W(k).
%   No information about the variance of the cross spectra is normally
%   given. (That is, covH(K1,K2,k) = 0 for K1 not equal to K2.)
%
%   If the model M is not a time series, use FREQRESP(m('n')) to obtain
%   the spectrum information of the noise (output disturbance) signals.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.14.4.8 $  $Date: 2008/10/02 18:47:18 $

if strcmpi(sys.Units,'hz')
    sys = chgunits(sys,'rad/s');
end
if strncmpi(sys.Units,'1',1) || strncmpi(sys.Units,'c',1)
    uni = sys.Units;
    tu = uni(findstr(uni,'/')+1:end);
    newu = ['rad/',tu];
    sys = chgunits(sys,newu);
end
w=sys.Frequency;
%idx = 1:length(w);
if nargin==2 && ~isempty(wdes) 
    if numel(wdes)>2
        ctrlMsgUtils.warning('Ident:analysis:idfrdFreqVecSpecIgnored')
    end
    idx = find(w<=max(wdes)&w>=min(wdes));
    sys = fselect(sys,idx);
    w = w(idx);
end
fr = sys.ResponseData;
[ny,nu,N] = size(fr);

if nu>0
    fr1 = fr;
    covff=sys.CovarianceData;
else
    fr1 = sys.SpectrumData;
    covff = sys.NoiseCovariance;
end
T = sys.Ts;
delays = sys.InputDelay;
if isempty(delays),
    delays=zeros(nu,1);
end
if T>0,
    delays = T*delays;
end
for ku = 1:nu
    if delays(ku)~=0
        fr1(:,ku,:) = fr1(:,ku,:).*reshape(ones(ny,1)*(exp(-i*w.'*delays(ku))),ny,1,length(w));
    end
end
