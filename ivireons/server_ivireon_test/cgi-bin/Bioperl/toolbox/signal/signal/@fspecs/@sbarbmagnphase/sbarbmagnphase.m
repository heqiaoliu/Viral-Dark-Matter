function this = sbarbmagnphase(varargin)
%SBARBMAGNPHASE   Construct a SBARBMAGNPHASE object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:01 $

this = fspecs.sbarbmagnphase;

respstr = 'Single-Band Arbitrary Magnitude and Phase';
fstart = 1;
fstop = 1;
nargsnoFs = 4;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
% [EOF]
