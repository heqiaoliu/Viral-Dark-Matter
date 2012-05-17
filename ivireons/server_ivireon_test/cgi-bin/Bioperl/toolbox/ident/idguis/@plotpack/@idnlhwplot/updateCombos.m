function updateCombos(this)
% update I/O and linear block's channel related combos

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:40 $

% input NL
ustr = get(this.UIs.InputCombo,'String');
selstr = ustr{get(this.UIs.InputCombo,'Value')};

newstr = this.getInputComboString;
set(this.UIs.InputCombo,'string',newstr);
Ind = find(strcmp(newstr,selstr));
%C = get(this.UIs.InputCombo,'Callback');
if isempty(Ind)
    Ind = 1;   
end

this.Current.InputComboValue = Ind;
set(this.UIs.InputCombo,'Value',Ind);
%C(this.UIs.InputCombo,[]) %execute callback

% output NL
ystr = get(this.UIs.OutputCombo,'String');
selstr = ystr{get(this.UIs.OutputCombo,'Value')};

newstr = this.getOutputComboString;
set(this.UIs.OutputCombo,'string',newstr);
Ind = find(strcmp(newstr,selstr));
if isempty(Ind)
    Ind = 1;   
end
this.Current.OutputComboValue = Ind;
set(this.UIs.OutputCombo,'Value',Ind);

% linear combo
str = get(this.UIs.LinearCombo,'String');
selstr = str{get(this.UIs.LinearCombo,'Value')};

[newstr,newtag] = this.getLinearComboString;
set(this.UIs.LinearCombo,'string',newstr,'userdata',newtag);
Ind = find(strcmp(newstr,selstr));
if isempty(Ind)
    Ind = 1;   
end
this.Current.LinearComboValue = Ind;
set(this.UIs.LinearCombo,'Value',Ind);

%this.showPlot;
