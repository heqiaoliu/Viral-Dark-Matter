function ChildList=allchild(HandleList)
%ALLCHILD Get all object children
%   ChildList=ALLCHILD(HandleList) returns the list of all children 
%   (including ones with hidden handles) for each handle.  If 
%   HandleList is a single element, the output is returned in a 
%   vector.  Otherwise, the output is a cell array.
%
%   Example:
%       get(gca,'children')
%           %or
%       allchild(gca)
%
%   See also GET, FINDALL.

%   Loren Dean
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.5 $ $Date: 2009/06/22 14:42:52 $

error(nargchk(1,1,nargin));

% figure out which, if any, items in list don't refer to hg objects
hgIdx = ishghandle(HandleList); % index of hghandles in list
nonHGHandleList = HandleList(~hgIdx); 

% if any of the items in the nonHGHandlList aren't handles, error out
if ~isempty(nonHGHandleList) && ~all(ishandle(nonHGHandleList)),
  error('MATLAB:allchild:InvalidHandles', 'Invalid handles passed to ALLCHILD.')
end  

Temp=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
ChildList=get(HandleList,'Children');
set(0,'ShowHiddenHandles',Temp);
