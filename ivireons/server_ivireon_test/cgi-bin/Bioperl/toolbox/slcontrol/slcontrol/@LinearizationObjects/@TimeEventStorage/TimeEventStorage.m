function hout = TimeEventStorage
% TimeEventStorage Constructor to create a singleton handle to the storage
%  class

%  Author(s): John Glass
%  Copyright 1986-2006 The MathWorks, Inc.

mlock
persistent this

if isempty(this)
    this = LinearizationObjects.TimeEventStorage;
end

hout = this;