function this = bpcutoffwap(varargin)
%BPCUTOFFWAP   Construct a BPCUTOFFWAP object.

%   Author(s): V. Pellissier
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:49:49 $

this = fspecs.bpcutoffwap;

respstr = 'Bandpass with cutoff and passband ripple';
fstart = 1;
fstop = 1;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
