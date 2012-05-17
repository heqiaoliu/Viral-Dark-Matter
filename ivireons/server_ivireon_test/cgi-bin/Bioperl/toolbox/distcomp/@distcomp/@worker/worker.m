function obj = worker(proxyWorker)
; %#ok Undocumented
%Protected constructor for worker matlab objects that is called by
%findresource to create appropriate objects

% Copyright 2004-2006 The MathWorks, Inc.

% Construct the base object
obj = distcomp.worker;
% Call abstract base class constructor
obj.abstractjobqueue(proxyWorker);
