function tstable_childnameupdate(h,varargin)
%Callback that updates the name of the tscollection members in response to
%a child tsnode name change event.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2008/12/29 02:11:50 $

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

Names = get(h.getChildren,{'Label'});
Data = cell(h.Handles.membersTable.getModel.getData);
Data(:,1) = Names;
headings = {xlate('Name'),xlate('Data Cols'),xlate('Data Units')};
h.Handles.membersTable.getModel.setDataVector(Data,headings,h.Handles.membersTable);



