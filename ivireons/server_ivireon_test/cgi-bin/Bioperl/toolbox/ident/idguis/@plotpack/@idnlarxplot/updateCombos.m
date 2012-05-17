function updateCombos(this)
% update output combo
% called only in GUI context

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:28 $

% output 
ystr = get(this.UIs.OutputCombo,'String');
selstr = ystr{get(this.UIs.OutputCombo,'Value')}; %currently selected output

newstr = this.getOutputComboString;
set(this.UIs.OutputCombo,'string',newstr);
Ind = find(strcmp(newstr,selstr));
if isempty(Ind)
    Ind = 1;   
end

this.Current.OutputComboValue = Ind;
set(this.UIs.OutputCombo,'Value',Ind);

% refresh regressor lists in the two combos
comboschanged = this.refreshControlPanel;

if comboschanged
    this.showPlot;
end
