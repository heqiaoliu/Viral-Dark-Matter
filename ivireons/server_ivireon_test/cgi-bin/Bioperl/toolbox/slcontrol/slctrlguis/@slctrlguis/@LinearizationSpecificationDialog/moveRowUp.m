function moveRowUp(this, dlgSrc) 
% moveRowUp

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:24 $

row = this.Data.TableRowFocus;
if row > 1
    this.Data.PNPVTableData([row-1,row],:) = this.Data.PNPVTableData([row,row-1],:);
    this.Data.TableRowFocus = this.Data.TableRowFocus-1;
end

this.refresh(dlgSrc);