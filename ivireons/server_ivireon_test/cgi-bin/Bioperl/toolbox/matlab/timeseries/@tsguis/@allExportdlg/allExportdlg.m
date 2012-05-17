function this = allExportdlg(varargin)
% EXCELIMPORTDLG is the constructor of the class, which imports time series
% from an excel workbook into tstool

% Author: Rong Chen 
% Revised: 
% Copyright 2004-2005 The MathWorks, Inc.

% -------------------------------------------------------------------------
% create a singleton of this import dialog
% -------------------------------------------------------------------------
mlock
persistent exportdlg;
if isempty(exportdlg) || ~ishandle(exportdlg)
    exportdlg = tsguis.allExportdlg;
    this = exportdlg; 
else
    this = exportdlg; 
end
