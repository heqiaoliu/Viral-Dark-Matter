function updateFreqRangeOnCurrentAxes(this,newLimit)
% update frequency range on the plots on current axis
% callback to time range change in GUI->Options->Freq range...

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/10/19 20:30:29

if this.Current.LinearPlotTypeComboValue~=2
    return
end

% current axes
[ax,un,yn] = this.getCurrentAxes;
uname = this.IONames.u{un};
yname = this.IONames.y{yn};

if isempty(ax(1)) || ~ishandle(ax(1))
    return;
end

% models on current axes
maglines = findobj(ax(1),'type','line'); maglines = maglines(end:-1:1); 
phaselines = findobj(ax(2),'type','line'); phaselines = phaselines(end:-1:1); 
modelnames = get(maglines,{'tag'});

L = length(modelnames);
for k = 1:L
    mobj = find(this.ModelData,'ModelName',modelnames{k});
    linmod = getlinmod(mobj.Model);
    [mag,ph,w] = bode(linmod,newLimit);
    
    iy = find(strcmp(yname,mobj.Model.OutputName));
    iu = find(strcmp(uname,mobj.Model.InputName));
    
    set(maglines(k),'xdata',w,'ydata',squeeze(mag(iy,iu,:)));
    set(phaselines(k),'xdata',w,'ydata',squeeze(ph(iy,iu,:)));
end
