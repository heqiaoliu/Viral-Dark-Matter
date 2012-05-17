function this = sbarbmagnphaseiir(varargin)
%SBARBMAGNPHASEIIR   Construct a SBARBMAGNPHASEIIR object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:07 $

this = fspecs.sbarbmagnphaseiir;
respstr = 'Single-Band Arbitrary Magnitude and Phase IIR';
fstart = 1;
fstop = 1;
nargsnoFs = 4;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
