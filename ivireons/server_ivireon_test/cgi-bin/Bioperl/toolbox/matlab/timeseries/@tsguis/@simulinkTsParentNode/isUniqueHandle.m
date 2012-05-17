function [isUnique,existingNodeName] = isUniqueHandle(h,ts)
%Check if the object ts already exists in the GUI. This check is required
%because Logs objects can't be deep copied (currently).
% 
% This check  is not required if Tsarray or Timeseries objects are being
% imported because they are deep-copied on explicit import (not when
% modeldatalogs is imported and they are contained inside them).

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:59:48 $

isUnique = true;
existingNodeName = '';


% check all *logs objects..
a1 = h.getChildren.find('AllowsChildren',true);
if isempty(a1)
    return
end
a2 = h.getChildren.find('AllowsChildren',true,...
    '-class','tsguis.simulinkTsArrayNode');

%list of "can't be copied" data nodes:
List = setdiff(a1,a2);
if ~isempty(List)
    SimHandles = List.get({'SimModelHandle'});
    Location = localismember(ts,SimHandles);
    if ~isempty(Location)
        isUnique = false;
        existingNodeName = List(Location).Label;
    end
end

%-------------------------------------------------------------------------
function I = localismember(a,objList)
%Compare handle 'a' to members of List to determine if a is a member of
%objList. I is an inetger showing first location of 'a' in objList.
%objList is a cell array of model handles.

I = [];
for ii = 1:numel(objList)
    if isequal(a,objList{ii})
        I = ii; 
        break;
    end
end