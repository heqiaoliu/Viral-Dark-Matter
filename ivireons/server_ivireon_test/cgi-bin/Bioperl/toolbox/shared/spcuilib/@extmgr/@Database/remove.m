function remove(this, varargin)
%REMOVE   Remove the specified child from the database.
%   REMOVE(H, CHILD)  Remove the CHILD from the database H.  If CHILD is
%   not contained within the database, this method is a no-op.
%
%   REMOVE(H, Param1, Value1, Param2, Value2, etc.)   Remove all database
%   children which match the param-value pairs specified.
%
%   REMOVE(H)   Remove all the children from the database.
%
%   See also extmgr.Database/ADD.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:53 $

if nargin==1
    % remove all children if the method is called as "remove(h)"
    iterator.removeChildren(this);
else
    
    if isa(varargin{1}, getChildClass(this))
        
        % Loop over the passed children and if they are contained as a
        % child object, remove them with the DISCONNECT method.
        for indx = 1:length(varargin)
            if isChild(this, varargin{indx})
                disconnect(varargin{indx});
            end
        end
    else
        
        % Find all children matching the settings passed in VARARGIN and
        % remove them from database.
        hChild = findChild(this, varargin{:});
        for indx = 1:numel(hChild)
            disconnect(hChild(indx));
        end
    end
end

% [EOF]
