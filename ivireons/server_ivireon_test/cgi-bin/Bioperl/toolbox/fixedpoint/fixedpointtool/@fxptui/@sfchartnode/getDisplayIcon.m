function val = getDisplayIcon(h)
%GETDISPLAYICON

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 02:18:24 $$

val = h.userdata.displayicon;
if(isa(h.daobject, 'DAStudio.Object'))
    %Get the SF object that this node points to.
    chart = fxptui.sfchartnode.getSFChartObject(h.daobject);
    if(isempty(h.userdata.displayicon) && ~isempty(chart))
        val = chart.getDisplayIcon;
        h.userdata.displayicon = val;
    end
  hasTopFlag = h.isdominantsystem('MinMaxOverflowLogging') && ~strcmp('UseLocalSettings', h.daobject.MinMaxOverflowLogging);
  hasBotFlag = h.isdominantsystem('DataTypeOverride') && ~strcmp('UseLocalSettings', h.daobject.DataTypeOverride);
  if(hasTopFlag && ~hasBotFlag)
     val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','chart_flag_top.png');
  end
  if(~hasTopFlag && hasBotFlag)
     val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','chart_flag_bottom.png');
  end
  if(hasTopFlag && hasBotFlag)
     val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','chart_flag_both.png');
  end
end
 

% [EOF]
