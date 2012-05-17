function addRow (this, dlgSrc) 
% addRow()

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:16 $
this.Data.PNPVTableData = [this.Data.PNPVTableData;{'',''}];
this.Data.TableRowFocus = size(this.Data.PNPVTableData,1);
this.refresh(dlgSrc);