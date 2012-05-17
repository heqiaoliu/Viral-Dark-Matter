function obj = getdistcompobjectroot
; %#ok Undocumented

% Copyright 2004-2006 The MathWorks, Inc.

% Lock this on a worker
persistent theRoot
if isempty(theRoot)
    theRoot = distcomp.objectroot;
    if system_dependent('isdmlworker')
        mlock;
    end
end
obj = theRoot;