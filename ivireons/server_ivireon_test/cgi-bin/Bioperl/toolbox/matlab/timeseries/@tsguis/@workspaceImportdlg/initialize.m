function flag=initialize(h)
% INITIALIZE is the function that tstool uses to display the import dialog
% given full path of the file in the 'filename' parameter.

% 1. the import dialog is resizable.
% 2. if the filename is the same as the last one, just display the import
%    dialog without reloading the file, otherwise, load the new file and
%    refresh the dialog.

% Author: Rong Chen 
% Revised: 
%   Copyright 1986-2005 The MathWorks, Inc.
%   % Revision % % Date %

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
h.defaultPositions;

% -------------------------------------------------------------------------
%% make visible if not first time openning
% -------------------------------------------------------------------------
if isfield(h.IOData,'formatcell')
    set(h.Handles.jBrowser,'Position', ...
                        [h.DefaultPos.Table_leftoffset ...
                         h.DefaultPos.Table_bottomoffset ...
                         h.DefaultPos.Table_width ...
                         h.DefaultPos.Table_height],'Visible','on');
    set(h.Handles.PNLdata,'Visible','on');
    set(h.Handles.PNLtime,'Visible','on');
    % update the dialog title
    set(h.Figure,'Name',xlate('Import Time Series From MATLAB Workspace'));
    flag=true;
    return
end

% -------------------------------------------------------------------------
%% reload the workspace variables into the browser
% -------------------------------------------------------------------------
try
    h.Handles.Browser.open;
    flag=true;
catch
    flag=false;
    h.IOData.FileName=[];
    errordlg('Unable to open the Workspace browser.','Time Series Tools','modal');
    return
end

% -------------------------------------------------------------------------
%% Initialize the internal state variables
% -------------------------------------------------------------------------
% update the dialog title
set(h.Figure,'Name',xlate('Import Time Series From MATLAB Workspace'));
% initialize state variables
h.IOData.checkLimitColumn=20;
h.IOData.checkLimitRow=20;
% no selection
h.IOData.SelectedColumns=[];
h.IOData.SelectedRows=[];
% no format information
h.IOData.formatcell=struct();
h.IOData.formatcell.name='';
h.IOData.formatcell.columnIndex=0;
h.IOData.formatcell.rowIndex=0;
h.IOData.formatcell.matlabFormatString = ...
    {'dd-mmm-yyyy HH:MM:SS' 'dd-mmm-yyyy' 'mm/dd/yy' 'mm/dd' 'HH:MM:SS' ...
    'HH:MM:SS PM' 'HH:MM' 'HH:MM PM' 'mmm.dd,yyyy HH:MM:SS' 'mmm.dd,yyyy' 'mm/dd/yyyy'};
h.IOData.formatcell.matlabFormatIndex = [0 1 2 6 13 14 15 16 21 22 23];
h.IOData.formatcell.matlabUnitString={'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'};

% -------------------------------------------------------------------------
%% Build data panel
% -------------------------------------------------------------------------
h.initializeDataPanel;

% -------------------------------------------------------------------------
%% Build time panel
% -------------------------------------------------------------------------
h.initializeTimePanel;

% -------------------------------------------------------------------------
%% set figure visible
% -------------------------------------------------------------------------
set(h.Handles.jBrowser,'Position', ...
    [h.DefaultPos.Table_leftoffset ...
     h.DefaultPos.Table_bottomoffset ...
     h.DefaultPos.Table_width ...
     h.DefaultPos.Table_height],'Visible','on');
set(h.Handles.PNLdata,'Visible','on');
set(h.Handles.PNLtime,'Visible','on');



