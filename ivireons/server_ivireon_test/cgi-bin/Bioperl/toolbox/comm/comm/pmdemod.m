function z = pmdemod(y,Fc,Fs,phasedev,ini_phase)
%PMDEMOD Phase demodulation.
%   Z = PMDEMOD(Y,Fc,Fs,PHASEDEV) demodulates the phase modulated signal Y
%   at the carrier frequency Fc (Hz). Fc and Y have sample frequency Fs
%   (Hz). PHASEDEV (Hz) is the phase deviation of the modulated signal.
%
%   Z = PMDEMOD(Y,Fc,Fs,PHASEDEV,INI_PHASE) specifies the initial phase
%   (radians) of the modulated signal.
% 
%   See also PMMOD, FMMOD, FMDEMOD.

%    Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/12/05 01:58:03 $

if(nargin>5)
    error('MATLAB:TooManyInputs','Too many input arguments.');
end

if(~isreal(y))
    error('comm:pmdemod:NonRealY','Y must be real.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 )
    error('comm:pmdemod:InvalidFs','Fs must be a real, positive scalar.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 )
    error('comm:pmdemod:InvalidFc','Fc must be a real, positive scalar.');
end

if(~isreal(phasedev) || ~isscalar(phasedev) || phasedev<=0)
    error('comm:pmdemod:InvalidPhaseDev',...
        'PHASEDEV must be a real, positive scalar.');
end

if(nargin<5 || isempty(ini_phase) )
    ini_phase = 0;
elseif(~isreal(ini_phase) || ~isscalar(ini_phase) )
    error('comm:pmdemod:InvalidIni_Phase',...
        'INI_PHASE must be a real scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<2*Fc)
    error('comm:pmdemod:FsLessThan2Fc','Fs must be at least 2*Fc');
end

% --- Assure that Y, if one dimensional, has the correct orientation --- %
len = size(y,1);
if(len ==1)
    y = y(:);
end

t = (0:1/Fs:((size(y,1)-1)/Fs))';
t = t(:,ones(1,size(y,2)));

yq = hilbert(y).*exp(-1i*(2*pi*Fc*t + ini_phase));
z = (1/phasedev)*angle(yq);
 
 % --- restore the output signal to the original orientation --- %
if(len == 1)
    z = z';
end

%EOF
