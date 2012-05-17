function xlim = calculateXLim(this)
%CALCULATEXLIM Calculate the default xlimits.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:42:54 $

tdo = this.TimeDisplayOffset;

if isscalar(tdo) || numel(this.Lines) <= numel(this.TimeDisplayOffset)
    xlim = [min(this.TimeDisplayOffset) ...
        max(this.TimeDisplayOffset)+this.TimeRange];
else
    xlim = [min([this.TimeDisplayOffset, 0]) ...
        max(this.TimeDisplayOffset)+this.TimeRange];
end

% [EOF]
