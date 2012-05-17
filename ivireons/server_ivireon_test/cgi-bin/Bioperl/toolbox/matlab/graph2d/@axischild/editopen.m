function aObj = editopen(aObj)
%AXISCHILD/EDITOPEN Edit axischild
%   This file is an internal helper function for plot annotation.

%   edit on doubleclick

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.12.4.4 $  $Date: 2009/06/22 14:32:17 $

selection = get(getobj(get(aObj,'Figure')),'SelectionHighlight');

%get a list of all handles currently selected in figure
hList = subsref(selection,substruct('.','HGHandle'));
if iscell(hList)
    hList=[hList{:}];
end
    
propedit(hList,'-noselect');
