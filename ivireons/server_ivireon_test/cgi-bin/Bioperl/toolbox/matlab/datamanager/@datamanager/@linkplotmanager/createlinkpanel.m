function createlinkpanel(h,f)

% Copyright 2008-2009 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.mwswing.*;
import com.mathworks.page.plottool.*;
import com.mathworks.page.plottool.plotbrowser.*;

if isempty(h.Figures)
    return
end
I = find([h.Figures.('Figure')]==f);
if isempty(I)
    return
end

% Get info about the graphics
ls = h.Figures(I).LinkedGraphics;
allProps = getplotbrowserproptable;
allPropClasses = cell(length(allProps),1);
for k=1:length(allProps)
    allPropClasses{k} = allProps{k}{1};
end
errorStates = false(length(ls),1);
gProxy = ChartObjectProxyFactory.createSeriesProxyArray(length(ls));
for k=1:length(ls)
   if ~feature('HGUsingMATLABClasses')
        gProxy(k) = ChartObjectProxyFactory.createSeriesProxy(handle(ls(k)),class(ls(k)));
   else
        gProxy(k) = ChartObjectProxyFactory.createHG2SeriesProxy(java(handle(ls(k))),class(ls(k)));
   end
   I1 = find(strcmp(class(ls(k)),allPropClasses));
   if ~isempty(I1)
      propNames = allProps{I1}{2};
      for j=1:length(propNames)
          ChartObjectProxyFactory.updateProperty(gProxy(k),propNames{j});
      end
      ChartObjectProxyFactory.updateProperty(gProxy(k),'XDataSource');
      ChartObjectProxyFactory.updateProperty(gProxy(k),'YDataSource');
      ChartObjectProxyFactory.updateProperty(gProxy(k),'ZDataSource');
      ChartObjectProxyFactory.updateProperty(gProxy(k),'DisplayName');
   end
   errorStates(k) = ~isempty(ls(k).findprop('LinkDataError')) && ~isempty(ls(k).LinkDataError);
end


lpp = h.Figures(I).Panel;
if isempty(lpp)
    lpp = awtcreate('com.mathworks.page.datamgr.linkedplots.LinkPlotPanel');
    lpp.initialize(gProxy,errorStates,h.Figures(I).IsEmpty);
    jf = datamanager.getJavaFrame(f);
    drawnow;
    lpp.addLinkPlotPanel(jf,java(f));
    drawnow
    h.Figures(I).Panel = lpp;
else
    lpp.showGraphicsNames(gProxy,errorStates,h.Figures(I).IsEmpty);
end