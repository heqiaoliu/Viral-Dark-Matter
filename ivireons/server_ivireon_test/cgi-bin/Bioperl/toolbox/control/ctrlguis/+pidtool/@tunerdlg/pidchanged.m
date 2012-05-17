function pidchanged(this) 
% PIDCHANGED  Enter a description here!
%
 
% Author(s): Rong Chen 08-Mar-2010
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:43 $

Settings = this.Handles.PreferenceDlg.PIDSettings;
datasrc = this.DataSrc;
% update only when there is a change
if ~(strcmp(datasrc.IFormula,Settings.IFormula) && ...
  strcmp(datasrc.DFormula,Settings.DFormula))
    % get new PID configuration
    datasrc.IFormula = Settings.IFormula;
    datasrc.DFormula = Settings.DFormula;
    % reset PIDTuningData
    datasrc.setPIDTuningData;
    % fastdesign
    this.fastdesign;
    % set status text
    this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_pidchanged_info'),'info');
end