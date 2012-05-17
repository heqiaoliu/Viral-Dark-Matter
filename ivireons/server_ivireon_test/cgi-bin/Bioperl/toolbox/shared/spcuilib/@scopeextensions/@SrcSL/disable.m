function disable(this)
%DISABLE  clean up

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/02/17 18:59:17 $

if this.ActiveSource
    close(this.Controls);
    disconnectData(this);
    clearDisplay(this);
    releaseData(this.Application);
end

% [EOF]
