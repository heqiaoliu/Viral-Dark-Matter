function changeDlgTab(hDlg, tag, index) %#ok
%CHANGEDLGTAB Callback to retain current ConfigDb dialog tab index.
%   changeDlgTab(hDlg, tag, index) is called whenever a new tab is
%   selected in the config dialog - either a top 'Type' tab, such as
%   'Tools','Sources', etc, or a bottom 'Name' tab, such as 'Files',
%   'Workspace', etc.  The top and bottom tab containers are separately
%   identified by the TAG string.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/04/11 16:22:41 $

this = getDialogSource(hDlg);

% Index describes which 'type' tab was just selected
% 0=General, 1=Sources, 2=Tools, etc
% Actually, it's not assured that 1=Sources,
% but 1,2,... are associated with the extension types
% in the order in which they are found

% Copy index to tracking property
% 'index' is passed in automatically by DDG, and is
% 0-based.  We store 0-based into property directly.

allTypes = this.Driver.RegisterDb.SortedTypeNames;
hidTypes = this.HiddenTypes;

% Get the indices of the "shown" types
[visTypes,idx] = setdiff(allTypes, hidTypes);

% Sort them and get the "index" element.
idx = sort(idx);
index = idx(index+1)-1;

this.SelectedType = index;

hDlg.setEnabled('Options', isOptionsEnabled(this));

% [EOF]
