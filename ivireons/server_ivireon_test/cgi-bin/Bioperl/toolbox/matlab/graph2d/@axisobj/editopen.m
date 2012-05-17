function aObj = editopen(aObj)
%AXISOBJ/EDITOPEN Edit axisobj object
%   This file is an internal helper function for plot annotation.

%   edit axis properties on double click

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.15.4.4 $  $Date: 2009/06/22 14:32:33 $

selection = get(getobj(get(aObj,'Figure')),'SelectionHighlight');

%get a list of all handles currently selected in figure
if ~isempty(selection)
    hList = subsref(selection,substruct('.','HGHandle'));
    if iscell(hList)
        hList=[hList{:}];
    end
else
    hgobj = aObj.scribehgobj;
    if ~isempty(hgobj)
        hList=hgobj.HGHandle;
    else
        hList=get(gcf,'CurrentAxes');
    end
end
    
propedit(hList,'-noselect');
