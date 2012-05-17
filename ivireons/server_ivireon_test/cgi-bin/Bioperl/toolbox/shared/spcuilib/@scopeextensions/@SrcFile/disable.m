function disable(this)
%DISABLE  override base class disable

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/06/13 15:28:47 $

if this.ActiveSource
    clearDisplay(this);
    releaseData(this.Application);
end

% [EOF]m
