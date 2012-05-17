function fullName = getFullName(this)
%GETFULLNAME Get the fullName.

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:22 $

blk = this.hSignalSelectMgr.getBlockHandle;
fullName = getFullName(blk(1));  % method on SLSignalSelect, hopefully
% [EOF]
