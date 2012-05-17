function updatePlantModel(this)
%UPDATEPLANTMODEL listen to the 'Plant' property of import dialog

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/03/26 17:54:09 $

%%
% import plant
this.DataSrc.G1 = this.Handles.ImportDlg.Plant;
this.DataSrc.setG2;
this.DataSrc.setPIDTuningData;
this.DataSrc.setBaseline;
% one-click design
this.design;
% reset GUI component
this.initialize;
% set status text
this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_plantimported_info'),'info');
