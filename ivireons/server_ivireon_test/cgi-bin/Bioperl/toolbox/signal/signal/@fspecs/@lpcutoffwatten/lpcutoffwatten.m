function this = lpcutoffwatten(varargin)
%LPCUTOFFWATTEN   Construct a LPCUTOFFWATTEN object.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:33:44 $

this = fspecs.lpcutoffwatten;

respstr = 'Lowpass with cutoff and attenuation';
fstart = 2;
fstop = 2;
nargsnoFs = 4;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
