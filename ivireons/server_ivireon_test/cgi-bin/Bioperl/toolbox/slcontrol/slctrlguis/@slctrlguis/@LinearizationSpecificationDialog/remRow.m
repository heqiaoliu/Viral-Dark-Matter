function remRow(this, dlgSrc) 
% remRow

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:27 $

row = this.Data.TableRowFocus;
this.Data.PNPVTableData(row,:) = [];
if (row == 1) && size(this.Data.PNPVTableData,1) > 0
    this.Data.TableRowFocus = 1;
elseif (row == 1)
    this.Data.TableRowFocus = 0;
else    
    this.Data.TableRowFocus = row - 1;
end
this.refresh(dlgSrc);