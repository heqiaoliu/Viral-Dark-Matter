function updateTimeRangeOnCurrentAxes(this,newLimit)
% update time range on the plots on current axis
% callback to time range change in GUI->Options->Time span...

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/10/19 20:30:29

Val = this.Current.LinearPlotTypeComboValue;
if (Val~=1) && (Val~=3)
    return
end

% current axes
[ax,un,yn] = this.getCurrentAxes;
uname = this.IONames.u{un};
yname = this.IONames.y{yn};

if isempty(ax) || ~ishandle(ax)
    return;
end

isStep  = Val==1;

% models on current axes
lines = findobj(ax,'type','line'); lines = lines(end:-1:1); 
modelnames = get(lines,{'tag'});

L = length(modelnames);
%y = cell(1,L); t = y;

for k = 1:L
    mobj = find(this.ModelData,'ModelName',modelnames{k});
    linmod = getlinmod(mobj.Model);
    if isStep
        [y,t] = step(linmod,newLimit);
    else
        [y,t] = impulse(linmod,newLimit);
        % do not update data object (limit changes are temporary)
    end
    
    iy = find(strcmp(yname,mobj.Model.OutputName));
    iu = find(strcmp(uname,mobj.Model.InputName));
    
    set(lines(k),'xdata',t,'ydata',squeeze(y(:,iy,iu)));    
end

