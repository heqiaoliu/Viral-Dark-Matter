function ClearEditBoxes(h) 
% CLEAREDITBOXES clear displayed time and indices

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% callback 

set(h.Handles.EDTFROM,'String','');
set(h.Handles.EDTTO,'String','');
set(h.Handles.EDTtimeSheetStart,'String','');
set(h.Handles.EDTtimeSheetEnd,'String','');
h.IOData.SelectedRows=[];
h.IOData.SelectedColumns=[];

