function exportplant(this) %#ok<*INUSD>
% EXPORTPLANT exports LTI plant model to base workspace

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:38 $

checkLabels = {pidtool.utPIDgetStrings('cst','exportdlg_label1'),...
    pidtool.utPIDgetStrings('cst','exportdlg_label2')};
varNames = {'G','C'}; 
items = {this.DataSrc.G,this.DataSrc.C};
export2wsdlg(checkLabels,varNames,items,pidtool.utPIDgetStrings('cst','exportdlg_title'));
