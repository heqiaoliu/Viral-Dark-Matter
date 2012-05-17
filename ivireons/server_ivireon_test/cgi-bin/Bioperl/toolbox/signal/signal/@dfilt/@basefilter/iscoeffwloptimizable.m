function [isresponsesupported, errormsg, errorid, args] = iscoeffwloptimizable(this)
%ISCOEFFWLOPTIMIZABLE True if the object is coeffwloptimizable

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:07 $

isresponsesupported = true;
errorid = '';
errormsg = '';
args = [];

% Test if filter is FIR
if ~isfir(this),
    isresponsesupported = false;
    errorid = 'FIRRequired';
    errormsg = 'The filter must be FIR for the coefficients word length optimization to take place.';
    return
end

% Test if designed with IFIR
hmethod = getfmethod(this);
method = hmethod.DesignAlgorithm;
if strcmpi(method,'Interpolated FIR'),
    isresponsesupported = false;
    errorid = 'IFIRNotSupported';
    errormsg = 'IFIR designs are not currently supported.';
    return;
end
    
% Test if the filter was designed by FDESIGN
f = getfdesign(this);
if isempty(f),
    isresponsesupported = false;
    errorid = 'FDESIGNRequired';
    errormsg = 'The filter must be designed with FDESIGN for the coefficients word length optimization to take place.';
    return
end

% Test supported responses
validresponses = {'Lowpass','Highpass','Halfband','Nyquist'};
if ~any(strcmpi(f.Response,validresponses)),
    isresponsesupported = false;
    errorid = 'InvalidResponse';
    errormsg = char(['Coefficients word length optimization is only supported for the following responses:', ...
        ' ',validresponses]);
    return
end

% Verify that the stopband attenuation is defined.
[Fpass, Fstop, Apass, Astop] = minwordlengthspecs(f,this);
if isempty(Astop),
    isresponsesupported = false;
    errorid = 'InvalidAstop';
    errormsg = ...
        'Cannot determine minimum wordlength for this design because the stopband attenuation is undefined.';
end

args.fdesignObj = f;
args.Fpass = Fpass;
args.Fstop = Fstop;
args.Apass = Apass;
args.Astop = Astop;

% [EOF]
