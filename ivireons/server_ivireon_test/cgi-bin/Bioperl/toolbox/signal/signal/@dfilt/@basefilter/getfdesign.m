function fdesign = getfdesign(this)
%GETFDESIGN   Get the fdesign.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:57:00 $

fdesign = this.privfdesign;
if ~isempty(fdesign)
    fdesign = copy(this.privfdesign);
end

% [EOF]
