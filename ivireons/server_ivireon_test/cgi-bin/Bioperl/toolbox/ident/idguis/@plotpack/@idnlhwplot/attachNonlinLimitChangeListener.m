function attachNonlinLimitChangeListener(this,ax)
% attach limit change listeners
% update lines for each nonlinearity (nlobjs) regardless of whether a line
% is visible or not.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:13 $

setAllowAxesRotate(rotate3d(this.Figure),ax,false);
hax = handle(ax);
listener = handle.listener(hax, findprop(hax,'Xlim'),'PropertyPostSet',...
    @(es,ed)localLimChangedCallback(ed,this,ax));

this.Listeners = [this.Listeners;listener];

%--------------------------------------------------------------------------
function localLimChangedCallback(ed,this,ax)

range = ed.NewValue;
axtype = get(ax,'userdata');
iostr = axtype(11:end);

if isequal(range,this.Range.(iostr))
    return
end

lines = findobj(ax,'type','line');
nlobjs = get(lines,{'userdata'});

N = this.NumSample;
xdata = (range(1):(range(2)-range(1))/(N-1):range(2))';

for k = 1:length(nlobjs)    
    ydata = evaluate(nlobjs{k}, xdata);
    %[min(ydata), max(ydata)]
    set(lines(k),'xdata',xdata,'ydata',ydata)
end

this.Range.(iostr) = range;
