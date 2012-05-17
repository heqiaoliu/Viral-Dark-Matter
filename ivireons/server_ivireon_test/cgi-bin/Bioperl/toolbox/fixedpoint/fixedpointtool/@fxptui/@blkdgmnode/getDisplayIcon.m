function val = getDisplayIcon(h)
%GETDISPLAYICON    

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:11:51 $$

val = '';
if(isa(h.daobject, 'DAStudio.Object'))
  val = h.daobject.getDisplayIcon;
  hasTopFlag = h.isdominantsystem('MinMaxOverflowLogging') && ~strcmp('UseLocalSettings', h.daobject.MinMaxOverflowLogging);
  hasBotFlag = h.isdominantsystem('DataTypeOverride') && ~strcmp('UseLocalSettings', h.daobject.DataTypeOverride);
  if(hasTopFlag && ~hasBotFlag)
      val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','model_flag_top.png');
  end
  if(~hasTopFlag && hasBotFlag)
      val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','model_flag_bottom.png');
  end
  if(hasTopFlag && hasBotFlag)
      val = fullfile('toolbox','fixedpoint','fixedpointtool','resources','model_flag_both.png');
  end
end
% [EOF]
