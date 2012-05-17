function this = bscutoffwbwp(varargin)
%BSCUTOFFWBWP   Construct a BSCUTOFFWBWP object.

%   Author(s): V. Pellissier
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:50:13 $

this = fspecs.bscutoffwbwp;

respstr = 'Bandstop with cutoff and passband width';
fstart = 1;
fstop = 1;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
