function this = bpweight(varargin)
%BPWEIGHT   Construct a BPWEIGHT object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:57:58 $

this = fspecs.bpweight;

respstr = 'Bandpass';
fstart = 2;
fstop = 5;
nargsnoFs = 8;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
