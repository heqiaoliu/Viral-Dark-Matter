function y = fmmod(x,Fc,Fs,freqdev,varargin)
%FMMOD Frequency modulation.
%   Y = FMMOD(X,Fc,Fs,FREQDEV) uses the message signal X to modulate the
%   carrier frequency Fc (Hz) and sample frequency Fs (Hz),  where Fs >
%   2*Fc. FREQDEV (Hz) is the frequency deviation of the modulated signal.
%
%   Y = FMMOD(X,Fc,Fs,FREQDEV,INI_PHASE) specifies the initial phase of
%   the modulation.
%
%   See also FMDEMOD, PMMOD, PMDEMOD.

%    Copyright 1996-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2007/08/03 21:17:32 $

error(nargchk(1,5,nargin,'struct'));

if(~isreal(x))
    error('comm:fmmmod:NonRealX','X must be real.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 )
    error('comm:fmmod:InvalidFs','Fs must be a real, positive scalar.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<0 )
    error('comm:fmmod:InvalidFc','Fc must be a real, positive scalar.');
end

if(~isreal(freqdev) || ~isscalar(freqdev) || freqdev<=0)
    error('comm:fmmod:InvalidFreqdev','FREQDEV must be a real, positive scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<2*Fc)
    error('comm:fmmod:FsLessThan2Fc','Fs must be at least 2*Fc.');
end

ini_phase = 0;
if(nargin == 5)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    end
    if(~isreal(ini_phase) || ~isscalar(ini_phase) )
        error('comm:fmmod:InvalidIni_Phase','INI_PHASE must be a real scalar.');
    end
end
    

% --- Assure that X, if one dimensional, has the correct orientation --- %
len = size(x,1);
if(len == 1)
    x = x(:);
end
   
t = (0:1/Fs:((size(x,1)-1)/Fs))';
t = t(:,ones(1,size(x,2)));

int_x = cumsum(x)/Fs;
y = cos(2*pi*Fc*t + 2*pi*freqdev*int_x + ini_phase);   

% --- restore the output signal to the original orientation --- %
if(len == 1)
    y = y';
end
    
% EOF