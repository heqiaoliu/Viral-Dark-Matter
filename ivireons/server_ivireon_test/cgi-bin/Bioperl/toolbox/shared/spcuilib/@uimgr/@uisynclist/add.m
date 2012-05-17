function add(h,fcnRaw,argsRaw, isDefault,dstPath)
%ADD Add a sync item to the list.
%   H.ADD(FCNRAW,ARGSRAW,DEFAULT,DSTPATH) adds an entry to the
%   synchronization list for this item or group.  All args pertain to the
%   DST item/widget, except for H which is the SRC item.
%
%     FCNRAW: function pointer
%     ARGSRAW: arguments
%       Taken together, @(h,ev)FCNRAW(ARGSRAW{:},ev) forms the
%       anonymous function FCN used as the sync listener.
%     DEFAULT indicates that the default sync function will be employed,
%       and that required default arguments must be set up.
%     DSTPATH is used for debug, and is the full path of dst
%       for the sync.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:31:51 $

% Add this to the bottom of the lists
%
% Is list empty?
%   -> could check any of the properties to determine this,
%      we're arbitrarily choosing to check h.Default
if isempty(h.Default)
    h.Default = isDefault;  % default sync fcn, or user mapping?
    h.DstName = {dstPath};  % only used for debug (explorer,warnings)
    h.FcnRaw  = {fcnRaw};   % most important part of SyncList entry
    h.ArgsRaw = {argsRaw};
else
    h.Default(end+1) = isDefault;
    h.DstName{end+1} = dstPath;
    h.FcnRaw{end+1}  = fcnRaw;
    h.ArgsRaw{end+1} = argsRaw;
end

% [EOF]
