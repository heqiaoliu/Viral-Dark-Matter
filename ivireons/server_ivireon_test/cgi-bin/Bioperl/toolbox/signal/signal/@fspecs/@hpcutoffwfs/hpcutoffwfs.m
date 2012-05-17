function this = hpcutoffwfs(varargin)
%HPCUTOFFWFS   Construct a HPCUTOFFWFS object.

%   Author(s): V. Pellissier
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:50:37 $

this = fspecs.hpcutoffwfs;

respstr = 'Highpass with cutoff and stopband frequency';
fstart = 1;
fstop = 1;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
