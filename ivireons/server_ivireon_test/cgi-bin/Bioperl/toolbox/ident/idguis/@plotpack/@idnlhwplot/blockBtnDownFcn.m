function blockBtnDownFcn(this,es,Label)
% block diagram button down function

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:14 $

%set(b1.PHandle,'ButtonDownFcn',@blockBtnDown);
tag = get(es,'tag');
if strcmpi(this.Current.Block,tag)
    return;
end

% if this.isGUI
%     col = get(this.TopPanel,'backgroundcolor');
% else
%     col = 'w';
%end

% make the selected block green
set(this.PatchHandles,'FaceColor','w');
set(this.PatchHandles(2),'FaceColor','w');
set(es,'FaceColor','g');

% show right channel selection combo

combos = [this.UIs.LinearCombo,this.UIs.InputCombo,this.UIs.OutputCombo];
set(combos,'vis','off')
set(findobj(combos,'tag',tag),'vis','on');

if strcmpi(tag,'linear')
    set(this.UIs.LinearPlotTypeCombo,'vis','on')
    set(this.UIs.LinearPlotTypeText,'vis','on')
    % update channel text
    set(Label,'string','Select I/O pair:');
else
    set(this.UIs.LinearPlotTypeCombo,'vis','off')
    set(this.UIs.LinearPlotTypeText,'vis','off')
    set(Label,'string','Select nonlinearity at channel:')
end



% update plot
this.Current.Block = tag;
this.showPlot;
