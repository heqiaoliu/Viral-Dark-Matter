function this = excelImportdlg(parent)
% EXCELIMPORTDLG is the constructor of the class, which imports time series
% from an excel workbook into tstool

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

% -------------------------------------------------------------------------
% create a singleton of this import dialog
% -------------------------------------------------------------------------
this = tsguis.excelImportdlg; 
this.Parent = parent;

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
this.defaultPositions;

% -------------------------------------------------------------------------
% initiaize figure window
% -------------------------------------------------------------------------
% create the main figure window
this.Figure = this.Parent.Figure;

% -------------------------------------------------------------------------
% get default background colors for all components
% -------------------------------------------------------------------------
this.DefaultPos.FigureDefaultColor=get(this.Figure,'Color');
this.DefaultPos.EditDefaultColor=[1 1 1];

% -------------------------------------------------------------------------
% if WINDOWS PC OS, get a list of activex server.  if an excel comserver
% exists, try to establish a webcomponent connection as well as initialize
% the activex cotnrol to display, otherwise use uitable for display
% -------------------------------------------------------------------------
% excel comserver connection to the original source
% this.Handles.WebComponent=[];    
% excel activex control to display
this.Handles.ActiveX=[];
this.Handles.WebComponent=[];
% uitable to display
this.Handles.tsTable=[];
% check
if ispc
    % windows pc os
    if ~isempty(this.Parent.DefaultPos.actxProgID)
        % excel comserver exists
        try
            % create the activex to display
            if isempty(findstr('owc.',lower(this.Parent.DefaultPos.actxProgID{end})))
                % 'OWC.' means an old version of actx ctrl which is not
                % supported by us.  Only OWC10 or OWC11 work.
                [this.Handles.ActiveX, this.Handles.ActiveXControlHandle] = ...
                    actxcontrol(this.Parent.DefaultPos.actxProgID{end},...
                    [0,0,1,1],...
                    this.Figure);
                %set(this.Handles.ActiveXControlHandle,'parent',h.Handles.PNLdata)
                this.Handles.ActiveXControlHandle=handle(this.Handles.ActiveXControlHandle);
                % add a handles property to ActX for accessing the other UI controls
                this.Handles.ActiveX.addproperty('handle');
                this.Handles.ActiveX.handle=this;
                % create webcomponent connection
                % this.Handles.WebComponent = actxserver('Excel.Application');
                % this.Handles.WebComponent.Visible = 0;
            else
                this.Handles.ActiveX=[];
            end
        catch
            % if error, use uitable for display
            this.Handles.ActiveX=[];
%             this.Handles.WebComponent=[];
        end
    end
end

% -------------------------------------------------------------------------
% other initialization
% -------------------------------------------------------------------------
this.IOData.FileName='';
this.IOData.SelectedRows=[];
this.IOData.SelectedColumns=[];
this.IOData.checkLimit=20;


