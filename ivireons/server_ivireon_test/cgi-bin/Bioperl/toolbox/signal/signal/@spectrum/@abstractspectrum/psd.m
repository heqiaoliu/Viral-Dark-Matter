function varargout = psd(this,x,varargin)
%PSD   Power Spectral Density (PSD) estimate.
%   Type help spectrum/psd for help.

%   Author(s): P. Pacheco
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $Date: 2007/12/14 15:14:21 $

error(nargchk(2,12,nargin,'struct'));
[x,lenX] = checkinputsigdim(x);% Column'izes x if a row vector.

hopts = uddpvparse('dspopts.spectrum',{'psdopts',this,x},varargin{:});

% Call psd of concrete class.
[hopts,opts] = saopts(this,lenX,hopts); % Opts for spectral analysis fcns.
[Pxx W] = thispsd(this,x,opts);  % Produces spectrum with pos freq only!

% %Initialize Confidence Interval if no computation is required 
CI = [];
%
% Create a dspdata object and center-DC if necessary.
%
% p* fcns return spectrums w/ pos freq only, so call centerDC if requested.
centerDCcache = hopts.CenterDC;
hopts.CenterDC=false;            % Temporary

% Define valid options for dspdata object.
propName = getrangepropname(hopts);
propValue= get(hopts,propName);
dspdataOpts = {'ConfLevel',hopts.ConfLevel,'ConfInterval',CI,...
    'CenterDC',hopts.CenterDC,'Fs',hopts.Fs,propName,propValue};

hpsd = dspdata.psd(Pxx,W,dspdataOpts{:});
if centerDCcache, 
    centerdc(hpsd);
end
hopts.CenterDC = centerDCcache;  % Restore original value.

% Calculation of Confidence Interval
if(isnumeric(hopts.ConfLevel))    
    CL = hopts.ConfLevel;
    Pxx = hpsd.Data;
    W = hpsd.Frequencies;
    
    CI = confinterval(this,x,Pxx,W,CL); 
    dspdataOpts = {'ConfLevel',hopts.ConfLevel,'ConfInterval',CI,...
    'CenterDC',hopts.CenterDC,'Fs',hopts.Fs,propName,propValue};  
    hpsd = dspdata.psd(Pxx,W,dspdataOpts{:});
end  

% Store a spectrum object in the data obj's metadata property.
hpsd.Metadata.setsourcespectrum(this);

if nargout == 0,   
    plot(hpsd);  
else
    varargout{1} = hpsd;
end

% [EOF]
