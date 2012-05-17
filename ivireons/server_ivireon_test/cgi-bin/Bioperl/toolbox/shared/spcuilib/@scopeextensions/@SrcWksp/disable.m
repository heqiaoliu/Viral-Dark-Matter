function disable(this)
%DISABLE Called when extension is disabled, overloaded for SrcWksp.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/10/29 16:08:59 $

if this.ActiveSource
    % Stop the controls from sending more information up to the
    % source/visual combo.
    close(this.Controls);
    clearDisplay(this);
    releaseData(this.Application);
end

% [EOF]
