function enableRuntimeData(this, val)
%ENABLEDATA <short description>
%   OUT = ENABLEDATA(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:19 $

if ~isempty(this.hSignalData)
    if nargin<2, val=true; end
    this.hSignalData.EnableRTO(val);
end

% [EOF]
