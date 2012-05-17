function this = multibandmagnphase(varargin)
%MULTIBANDMAGNPHASE   Construct a MULTIBANDMAGNPHASE object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:46 $

this = fspecs.multibandmagnphase;

respstr = 'Multi-Band Arbitrary Magnitude and Phase';
fstart = 1;
fstop = 1;
nargsnoFs = 2;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
% [EOF]
