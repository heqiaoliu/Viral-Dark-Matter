function show(this)
% show the regressor editor dialog

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:04:20 $

% set ModelCopy -> set in updateDialogContents

% update the contents of regressor dialog tables
this.updateDialogContents;

% now show the dialog
javaMethodEDT('setVisible',this.jMainPanel,true);
