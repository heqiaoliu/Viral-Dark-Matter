function constructor(h,varargin)
%CONSTRUCTOR   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:30:45 $

respstr = h.ResponseType;
fstart = 3;
fstop = 3;
nargsnoFs = 3;
fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
