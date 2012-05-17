function this = lpstopfpass(varargin)
%LPSTOPFPASS   Construct a LPSTOPFPASS object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:59:41 $

this = fspecs.lpstopfpass;

respstr = 'Lowpass with passband frequency';
fstart = 1;
fstop = 2;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
