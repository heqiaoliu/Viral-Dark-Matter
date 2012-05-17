function this = bscutoffwbws(varargin)
%BSCUTOFFWBWS   Construct a BSCUTOFFWBWS object.

%   Author(s): V. Pellissier
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:50:17 $

this = fspecs.bscutoffwbws;

respstr = 'Bandstop with cutoff and stopband width';
fstart = 1;
fstop = 1;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
