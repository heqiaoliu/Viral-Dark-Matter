 function filterRemoveCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.
idx = this.filterStateIdx + 1;
keys = this.filterState.keys;
this.filterState.remove(keys(idx));
