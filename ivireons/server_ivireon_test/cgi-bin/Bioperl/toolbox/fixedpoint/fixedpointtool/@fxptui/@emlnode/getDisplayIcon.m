function val = getDisplayIcon(h)
%GETDISPLAYICON

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:11:52 $$

val = h.userdata.displayicon;
if(isa(h.daobject, 'DAStudio.Object'))
  chart = h.daobject.getHierarchicalChildren;
  if(isa(chart, 'DAStudio.Object'))
    if(isempty(h.userdata.displayicon))
      val = chart.getDisplayIcon;
      h.userdata.displayicon = val;
    end
    hasTopFlag = h.isdominantsystem('MinMaxOverflowLogging') && ~strcmp('UseLocalSettings', h.daobject.MinMaxOverflowLogging);
    hasBotFlag = h.isdominantsystem('DataTypeOverride') && ~strcmp('UseLocalSettings', h.daobject.DataTypeOverride);
    if(hasTopFlag && ~hasBotFlag)
        val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','eml_flag_top.png');
    end
    if(~hasTopFlag && hasBotFlag)
        val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','eml_flag_bottom.png');
    end
    if(hasTopFlag && hasBotFlag)
        val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','eml_flag_both.png');
    end
  end
end

% [EOF]
