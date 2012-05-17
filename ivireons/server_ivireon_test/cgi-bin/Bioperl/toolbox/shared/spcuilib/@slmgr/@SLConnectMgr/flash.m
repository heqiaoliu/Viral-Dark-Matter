function flash(this)
%FLASH    <short description>
%   OUT = FLASH(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:20 $

if ~isempty(this.hSignalSelectMgr)
    flash(this.hSignalSelectMgr);
end

% [EOF]
