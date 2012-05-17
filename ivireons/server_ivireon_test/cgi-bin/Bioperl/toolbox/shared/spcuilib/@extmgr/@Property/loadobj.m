function this = loadobj(s)
%LOADOBJ  Load this object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:04 $

if isstruct(s)
    this = extmgr.Property;
    
    % If we cannot find the type, assume it is an undefined enumeration.  Load
    % it in as a string.  When we copy values over to the final configuration,
    % we should have all the enumerations loaded then.
    if isempty(findtype(s.Type))
        s.Type = 'string';
    end
    this.init(s.Name, s.Type, s.Value, s.Status);
else
    this = s;
end

% [EOF]
