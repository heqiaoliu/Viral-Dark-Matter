function this = csvImportdlg(parent)
% EXCELIMPORTDLG is the constructor of the class, which imports time series
% from an excel workbook into tstool

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

% -------------------------------------------------------------------------
% create a singleton of this import dialog
% -------------------------------------------------------------------------
this = tsguis.csvImportdlg; 
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

% uitable to display
this.Handles.tsTable = [];

% -------------------------------------------------------------------------
% other initialization
% -------------------------------------------------------------------------
this.IOData.FileName='';
this.IOData.SelectedRows=[];
this.IOData.SelectedColumns=[];
this.IOData.checkLimit=20;


