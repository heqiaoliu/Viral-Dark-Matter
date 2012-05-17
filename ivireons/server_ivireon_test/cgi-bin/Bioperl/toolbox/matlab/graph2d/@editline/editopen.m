function aObj = editopen(aObj)
%EDITLINE/EDITOPEN Edit editline object
%   This file is an internal helper function for plot annotation.

%   open edit dialog on double click

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.17.4.4 $  $Date: 2009/06/22 14:33:19 $


selection = get(getobj(get(aObj,'Figure')),'SelectionHighlight');

%get a list of all handles currently selected in figure
hList = subsref(selection,substruct('.','HGHandle'));
if iscell(hList)
    hList=[hList{:}];
end
    
propedit(hList,'-noselect');
