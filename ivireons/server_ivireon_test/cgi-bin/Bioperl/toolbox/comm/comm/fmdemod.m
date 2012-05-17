function z = fmdemod(y,Fc,Fs,freqdev,ini_phase)
%FMDEMOD Frequency demodulation.
%   Z = FMDEMOD(Y,Fc,Fs,FREQDEV) demodulates the FM modulated signal Y at
%   the carrier frequency Fc (Hz). Y and Fc have sample frequency Fs (Hz).
%   FREQDEV is the frequency deviation (Hz) of the modulated signal.
%
%   Z = FMDEMOD(Y,Fc,Fs,FREQDEV,INI_PHASE) specifies the initial phase of
%   the modulated signal.
%
%   See also FMMOD, PMMOD, PMDEMOD.

%    Copyright 1996-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:14:29 $

error(nargchk(1,5,nargin,'struct'));
% if(nargin>5)
%     error('Too many input arguments.');
% end

if(~isreal(y))
    error('comm:fmdemod:NonRealY','Y must be real.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 )
    error('comm:fmdemod:InvalidFs','Fs must be a real, positive scalar.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 )
    error('comm:fmdemod:InvalidFc','Fc must be a real, positive scalar.');
end

if(~isreal(freqdev) || ~isscalar(freqdev) || freqdev<=0)
    error('comm:fmdemod:InvalidFreqdev','FREQDEV must be a real, positive scalar.');
end

if(nargin<5 || isempty(ini_phase) )
    ini_phase = 0;
elseif(~isreal(ini_phase) || ~isscalar(ini_phase)  )
    error('comm:fmdemod:InvalidIni_Phase','INI_PHASE must be a real scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<2*Fc)
    error('comm:fmdemod:FsLessThan2Fc','Fs must be at least 2*Fc');
end

% --- Assure that Y, if one dimensional, has the correct orientation --- %
len = size(y,1);
if(len==1)
    y = y(:);
end


t = (0:1/Fs:((size(y,1)-1)/Fs))';
t = t(:,ones(1,size(y,2)));

yq = hilbert(y).*exp(-j*2*pi*Fc*t-ini_phase);
z = (1/(2*pi*freqdev))*[zeros(1,size(yq,2)); diff(unwrap(angle(yq)))*Fs];

% --- restore the output signal to the original orientation --- %
if(len == 1)
    z = z';
end




   

