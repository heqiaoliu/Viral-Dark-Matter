function y = pmmod(x,Fc,Fs,phasedev,varargin)
%PMMOD Phase modulation.
%   Y = PMMOD(X,Fc,Fs,PHASEDEV) uses the message signal X to phase modulate
%   the carrier frequency Fc (Hz). Fc and X have sample frequency Fs (Hz),
%   where Fs >= 2*Fc. PHASEDEV (radians) is the phase deviation of the
%   modulated signal.
%
%   Y = PMMOD(X,Fc,Fs,PHASEDEV,INI_PHASE) specifies the initial phase
%   (radians) of the modulated signal.
%
%   See also PMDEMOD, FMMOD, FMDEMOD.

%    Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/05 01:58:06 $

if(nargin>5)
    error('comm:pmmod:tooManyInputs','Too many input arguments.');
end

if(~isreal(x)|| ~ isnumeric(x))
    error('comm:pmmod:NonRealX','X must be real.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 || ~isnumeric(Fs) )
    error('comm:pmmod:InvalidFs','Fs must be a real, positive scalar.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 ||~isnumeric(Fc) )
    error('comm:pmmod:InvalidFc','Fc must be a real, positive scalar.');
end

if(~isreal(phasedev) || ~isscalar(phasedev) || phasedev<=0 ||~isnumeric(phasedev) )
    error('comm:pmmod:InvalidPhaseDev','PHASEDEV must be a real, positive scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<2*Fc)
    error('comm:pmmod:FsLessThan2Fc','Fs must be at least 2*Fc');
end

ini_phase = 0;
if(nargin == 5)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    end
    if(~isreal(ini_phase) || ~isscalar(ini_phase) || ~isnumeric(ini_phase) )
        error('comm:pmmod:InvalidIni_Phase','INI_PHASE must be a real scalar.');
    end
end

% --- Assure that X, if one dimensional, has the correct orientation --- %
len = size(x,1);
if(len == 1)
    x = x(:);
end

t = (0:1/Fs:((size(x,1)-1)/Fs))';
t = t(:,ones(1,size(x,2)));
  
y = cos(2*pi*Fc*t + phasedev*x + ini_phase);   

% --- restore the output signal to the original orientation --- %
if(len == 1)
    y = y';
end

%EOF