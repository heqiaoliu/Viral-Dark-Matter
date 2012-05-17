function drag(this)

% Initiate a drag for this single graphical object

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.page.plottool.plotbrowser.*;
 
if ~strcmp(get(gcbf,'SelectionType'),'normal')
    return
end

fig = ancestor(this.HGHandle,'figure');
jf = datamanager.getJavaFrame(fig);
drawnow

% Create a transferable string to drop based on the current graphical
% object rather than all items selected in the figure
Isel = datamanager.var2string(this.getArraySelection);

% Create a graphics proxy to represent the brushing annotation
allProps = getplotbrowserproptable;
allPropClasses = cell(length(allProps),1);
for k=1:length(allProps)
    allPropClasses{k} = allProps{k}{1};
end
gProxy = ChartObjectProxyFactory.createSeriesProxy(handle(this.SelectionHandles(1)),class(handle(this.SelectionHandles)));
I1 = find(strcmp(class(handle(this.SelectionHandles)),allPropClasses));
if ~isempty(I1)
  propNames = allProps{I1}{2};
  for j=1:length(propNames)
      ChartObjectProxyFactory.updateProperty(gProxy,propNames{j});
  end
end

% Start the drag 
AxesDragRecogniser.dragGestureRecognized(jf.getAxisComponent,gProxy,Isel);


        
    