function importTsCallback(this,varargin)
%add members to tscollection 

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:57:33 $

% Add from import dialog

tmp = tsguis.tsImportdlg('Title','Import Time Series from MATLAB Workspace',...
           'HelpFile','d_import_fr_workspace',...
           'TypesAllowed',{'timeseries'});
tmp.open;
if isempty(tmp.OutputValue)
    return
else
    names = fieldnames(tmp.OutputValue);
    for i=1:length(names)
        ts = tmp.OutputValue.(names{i});
        this.addTsCallback(ts,names{i});
    end
end
