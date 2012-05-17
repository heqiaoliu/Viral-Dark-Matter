function this = hpiir(varargin)
%HPIIR   Construct a HPIIR object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:32:34 $

this = fspecs.hpiir;

respstr = 'Highpass';
fstart = 3;
fstop = 4;
nargsnoFs = 6;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
