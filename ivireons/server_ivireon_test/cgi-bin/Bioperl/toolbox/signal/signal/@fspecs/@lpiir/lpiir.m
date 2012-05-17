function this = lpiir(varargin)
%LPIIR   Construct a LPIIR object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:34:04 $

this = fspecs.lpiir;

respstr = 'Lowpass';
fstart = 3;
fstop = 4;
nargsnoFs = 6;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
