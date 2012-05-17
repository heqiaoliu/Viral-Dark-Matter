function varargout = msspectrum(this,x,varargin)
%MSSPECTRUM   Mean-square Spectrum estimate.
%   Type help spectrum/msspectrum for help.

%   Author(s): P. Pacheco
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $Date: 2007/12/14 15:14:42 $

error(nargchk(2,12,nargin,'struct'));
[x,lenX] = checkinputsigdim(x);% Column'izes x if a row vector.

hopts = uddpvparse('dspopts.spectrum',{'psdopts',this,x},varargin{:});

% Call msspectrum of concrete class.
[hopts,opts] = saopts(this,lenX,hopts); % Opts for spectral analysis fcns.
[Sxx W] = thismsspectrum(this,x,opts);

% %Initialize Confidence Interval if no computation is required  
CI = [];%
% Create a dspdata object and center-DC if necessary.
%
% p* fcns return spectrums w/ pos freq only, so centerDC if requested.
centerDCcache = hopts.CenterDC;
hopts.CenterDC=false;   

% Define valid options for dspdata object.
propName = getrangepropname(hopts);
propValue= get(hopts,propName);
dspdataOpts = {'ConfLevel',hopts.ConfLevel,'ConfInterval',CI,...
    'CenterDC',hopts.CenterDC,'Fs',hopts.Fs,propName,propValue};

hmss = dspdata.msspectrum(Sxx,W,dspdataOpts{:});
if centerDCcache, 
    centerdc(hmss);
end
hopts.centerDC = centerDCcache;

% Calculation of Confidence Interval
if(isnumeric(hopts.ConfLevel))    
    CL = hopts.ConfLevel;
    Sxx = hmss.Data;
    W = hmss.Frequencies;
    
    CI = confinterval(this,x,Sxx,W,CL);
    dspdataOpts = {'ConfLevel',hopts.ConfLevel,'ConfInterval',CI,...
    'CenterDC',hopts.CenterDC,'Fs',hopts.Fs,propName,propValue};   
    hmss = dspdata.msspectrum(Sxx,W,dspdataOpts{:});
end  

% Store a spectrum object in the data obj's metadata property.
hmss.Metadata.setsourcespectrum(this);

if nargout == 0,
    plot(hmss);
else
    varargout{1} = hmss;
end

% [EOF]
