function varargout = merge(this, hSource)
%MERGEPROPDB Merge properties from one object to another.
%   MERGEPROPDB(hTARGET, hSOURCE) Merge properties from hSOURCE to hTARGET.
%   If a property already exists on the target it is overwriten.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/02 13:09:59 $

if nargout > 0
    newPropDb = copy(this, 'children');
else
    newPropDb = this;
end

if ~isempty(hSource)
    % Merge each property in hConfig property database
    iterator.visitImmediateChildren(hSource, ...
        @(newProp) local_mergeOneProp(newPropDb,newProp));
end

if nargout > 0
    varargout{1} = newPropDb;
end

%%
function local_mergeOneProp(hPropertyDb,newProp)

oldProp = findProp(hPropertyDb,newProp.Name);

if isempty(oldProp);
    
    % Property not found, 
    hPropertyDb.add(copy(newProp));
else
    
    % Property found
    
    % Could explicity check data type of Value, but it's easier to just try
    % to set the value and see if an error occurs
    
    try
        % Copy value from newProp to PropertyDb entry
        oldProp.Value = newProp.Value;

        % Successful transfer of value!
        % Property is no longer the 'default' value from Register,
        % it's an 'active' value now:
        oldProp.Status = 'Active';
        
    catch e
        rethrow(e);
    end

end

% [EOF]
