function tagstr = getTag(this)
% get uicomponent's tag
% panels are tagged by I/O names

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:29 $

block = this.Current.Block;
if strcmpi(block,'input')
    %input NL
    v = this.Current.InputComboValue;
    str = this.getInputComboString;
    tagstr = sprintf('Input:%s',str{v});
elseif strcmpi(block,'output')
    %output NL
    v = this.Current.OutputComboValue;
    str = this.getOutputComboString;
    tagstr = sprintf('Output:%s',str{v});
else
    % linear model
    v0 = this.Current.LinearComboValue;
    str0 = this.getLinearComboString; 
    v = this.Current.LinearPlotTypeComboValue;
    %str = get(this.UIs.LinearPlotTypeCombo,'String');
    % tag name example: Linear:u1->y1:2 
    tagstr = sprintf('Linear:%s:%d',str0{v0},v);
end
