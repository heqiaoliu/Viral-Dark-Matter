function disableListeners(this)

% Copyright 2003-2006 The MathWorks, Inc.

if ~isempty(this.Listeners) 
    set(this.Listeners,'Enabled','off')
end
 
