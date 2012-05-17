function this = lpweight(varargin)
%LPWEIGHT   Construct a LPWEIGHT object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:59:47 $

this = fspecs.lpweight;

respstr = 'Lowpass';
fstart = 2;
fstop = 3;
nargsnoFs = 5;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
