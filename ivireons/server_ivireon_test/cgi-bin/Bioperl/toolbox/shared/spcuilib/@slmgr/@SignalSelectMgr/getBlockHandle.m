function blockHandle = getBlockHandle(this)
%GETBLOCKHANDLE Get the blockHandle.
%   OUT = GETBLOCKHANDLE(ARGS) <long description>

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:17 $

blockHandle = get(this.Signals, 'Block');

if iscell(blockHandle)
    if length(unique([blockHandle{:}])) == 1
        blockHandle = blockHandle{1};
    else
        blockHandle = [blockHandle{:}];
    end
end

% [EOF]
