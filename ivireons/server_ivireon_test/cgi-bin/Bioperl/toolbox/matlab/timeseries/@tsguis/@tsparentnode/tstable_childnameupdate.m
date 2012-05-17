function tstable_childnameupdate(h,varargin)
%Callback that updates the name of the tsparent members in response to
%a child tsnode/tscollection name change event.

%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2008/12/29 02:11:53 $

if isempty(h.Handles) || isempty(h.Handles.PNLtsTable) || ...
        ~ishghandle(h.Handles.PNLtsTable)
    return % No panel
end

Names = get(h.getChildren,{'Label'});
Data = cell(h.Handles.tsTable.getModel.getData);
Data(:,1) = Names;
headings = {xlate('Name'),xlate('Type'),xlate('Time Vector'),xlate('Description')};
h.Handles.tsTable.getModel.setDataVector(Data,headings,h.Handles.tsTable);

