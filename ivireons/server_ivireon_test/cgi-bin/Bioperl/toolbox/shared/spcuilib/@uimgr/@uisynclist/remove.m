function remove(h)
%REMOVE Remove all sync installer entries from the hierarchy item.
%   H.REMOVE removes all sync install items from hierarchy item H.
%   Previously installed widget sync remains in effect until UI
%   is re-rendered, however (via an unrender/rerender cycle).

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:31:53 $

% Remove all sync list items
h.Default = [];
h.DstName = {};
h.FcnRaw = {};
h.ArgsRaw = {};

% [EOF]
