function this = lpcutoffwas(varargin)
%LPCUTOFFWAS   Construct a LPCUTOFFWAS object.

%   Author(s): V. Pellissier
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:50:52 $

this = fspecs.lpcutoffwas;

respstr = 'Lowpass with cutoff and stopband attenuation';
fstart = 1;
fstop = 1;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% % [EOF]
