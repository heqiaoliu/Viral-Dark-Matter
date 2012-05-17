function this = loadobj(s)
%LOADOBJ  Load this object.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2009/09/09 21:28:57 $

if isstruct(s)
    this = extmgr.ConfigDb;
    
    this.Name        = s.Name;
    this.Description = s.Description;
    this.AllowConfigEnableChangedEvent = s.AllowConfigEnableChangedEvent;
    
    for indx = 1:length(s.Children)
        if ~isempty(s.Children(indx).Type) && ~isempty(s.Children(indx).Name)
            this.add(s.Children(indx));
        end
    end
else
    this = s;
end

% [EOF]
