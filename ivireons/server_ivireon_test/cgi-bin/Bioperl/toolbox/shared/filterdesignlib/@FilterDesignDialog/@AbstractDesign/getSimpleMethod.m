function simpleMethod = getSimpleMethod(this, laState)
%GETSIMPLEMETHOD   Get the simpleMethod.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/12 21:35:13 $

if nargin > 1 && ~isempty(laState)
    dm = laState.DesignMethod;
else
    dm = this.DesignMethod;
end

simpleMethod = lower(dm);

switch simpleMethod
    case 'chebyshev type i'
        simpleMethod = 'cheby1';
    case 'chebyshev type ii'
        simpleMethod = 'cheby2';
    case 'butterworth'
        simpleMethod = 'butter';
    case 'elliptic'
        simpleMethod = 'ellip';
    case 'fir least-squares'
        simpleMethod = 'firls';
    case 'fir constrained least-squares'
        simpleMethod = 'fircls';
    case 'maximally flat'
        simpleMethod = 'maxflat';        
    case 'iir least-squares'
        simpleMethod = 'iirls';
    case 'window'
        simpleMethod = 'window';
    case 'kaiser window'
        simpleMethod = 'kaiserwin';
    case 'iir least p-norm'
        simpleMethod = 'iirlpnorm';
    case 'interpolated fir'
        simpleMethod = 'ifir';
    case 'multistage equiripple'
        simpleMethod = 'multistage';
    case 'iir quasi-linear phase'
        simpleMethod = 'iirlinphase';
    case 'lagrange interpolation'
        simpleMethod = 'lagrange';
    case 'frequency sampling'
        simpleMethod = 'freqsamp';
end

% [EOF]
