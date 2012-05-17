function refreshIOCombos(this)
% refresh I/O combos when current model changes in GUI. 
% todo: delete this

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:34 $

h = this.CurrentModelHandle;
Ind =  h.Current.InputComboValue; %get(this.OutputCombo,'Value')-1;
set(this.InputCombo,'String',this.getInputComboString,'Value',Ind);

Ind =  h.Current.OutputComboValue; %get(this.OutputCombo,'Value')-1;
set(this.OutputCombo,'String',this.getOutputComboString,'Value',Ind);
