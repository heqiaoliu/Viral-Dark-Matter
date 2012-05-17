function this = bsiir(varargin)
%BSIIR   Construct a BSIIR object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:30:02 $

this = fspecs.bsiir;
respstr = 'Bandstop';
fstart = 3;
fstop = 5;
nargsnoFs = 8;
fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
