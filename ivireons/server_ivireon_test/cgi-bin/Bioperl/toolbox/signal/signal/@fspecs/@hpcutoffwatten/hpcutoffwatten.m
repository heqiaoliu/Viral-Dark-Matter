function this = hpcutoffwatten(varargin)
%HPCUTOFFWATTEN   Construct a HPCUTOFFWATTEN object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/12 21:36:42 $

this = fspecs.hpcutoffwatten;

respstr = 'Highpass with cutoff and attenuation';
fstart = 2;
fstop = 2;
nargsnoFs = 4;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
