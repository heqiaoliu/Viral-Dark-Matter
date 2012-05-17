function portIndices = getPortIndices(this)
%GETPORTINDICES Get the portIndices.
%   OUT = GETPORTINDICES(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:23 $

portIndices = this.hSignalSelectMgr.getPortIndices;

% [EOF]
