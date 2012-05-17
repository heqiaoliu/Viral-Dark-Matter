function [N, ff, aa, wts] = remezord(fcuts, mags, devs, varargin)
%REMEZORD  FIR order estimator (lowpass, highpass, bandpass, multiband)
%   REMEZORD is obsolete.  REMEZORD still works but may be removed in the
%   future. Use FIRPMORD instead.
%
%   See also FIRPMORD.

%   Author(s): J. H. McClellan, 10-28-91
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2007/12/14 15:05:58 $

%   References:
%     [1] Rabiner & Gold, Theory and Applications of DSP, pp. 156-7.     

error(nargchk(3,5,nargin,'struct'));
[N, ff, aa, wts] = firpmord(fcuts, mags, devs, varargin{:});

% [EOF] 
