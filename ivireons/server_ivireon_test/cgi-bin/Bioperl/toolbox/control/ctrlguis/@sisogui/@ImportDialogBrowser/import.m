function import(this)
%IMPORT 

%   Author(s): Craig Buhr
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2007/02/06 19:50:36 $

% get target, get selected, update @design object
idx = awtinvoke(this.Handles.ComboBox,'getSelectedIndex()');
Identifier=this.ImportDialog.ImportList{idx+1};

ModelIdx = awtinvoke(this.Handles.Table,'getSelectedRow()') + 1; %java to matlab indexing

if ModelIdx ~= 0 % no row selected if ModelIdx == 0
    this.ImportDialog.Design.(Identifier).Value = this.VarData{ModelIdx};
    this.ImportDialog.Design.(Identifier).Variable = this.VarNames{ModelIdx};
    refreshtable(this.ImportDialog);
end
