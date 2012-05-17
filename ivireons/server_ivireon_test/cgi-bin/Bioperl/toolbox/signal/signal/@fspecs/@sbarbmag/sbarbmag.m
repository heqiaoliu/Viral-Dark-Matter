function this = sbarbmag(varargin)
%SBARBMAG   Construct a SBARBMAG object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:35:25 $

this = fspecs.sbarbmag;

respstr = 'Single-Band Arbitrary Magnitude';
fstart = 1;
fstop = 1;
nargsnoFs = 3;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
% [EOF]
