function tstable(h,varargin)
%TSTABLE updates the dynamic contents of the tscollection's panel - members
%info, time-vector and current time information, by looking up the values
%from the tscollection object. This is equivalent of synctable method of
%tsnode.

%   Author(s): Rajiv Singh
%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2008/12/29 02:11:49 $


import javax.swing.*;

%% Method which builds/populates the timeseries table on the viewcontainer panel

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    h.refreshChildrenData(varargin{:});
    return % No panel
end

% refresh the timeseries members panel
if nargin>=2 && isa(varargin{1},'tsdata.dataChangeEvent')
    h.tscollectionMembersTable(varargin{2:end});
else
    h.tscollectionMembersTable(varargin{:});
end

% refresh the time-info containing entities - current time display and the
% time vector table
h.syncTimeInfoPanels(varargin{:});
