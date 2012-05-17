function LabelMap = DefaultLabelFcn(this)
%DEFAULTLABELFCN  Default implementation of LabelFcn.
%
%   Maps label, units, and transform properties into HG label contents.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:50 $

LabelMap = struct(...
   'XLabel',sprintf('%s%s',this.XLabel,LocalUnitInfo(this.XUnits)),...
   'XLabelStyle',this.XLabelStyle,...
   'YLabel',{{sprintf('%s%s',this.YLabel{1},LocalUnitInfo(this.YUnits{1}));...
      sprintf('%s%s',this.YLabel{2},LocalUnitInfo(this.YUnits{2}))}},...
   'YLabelStyle',this.YLabelStyle);
   
%---------- Local Functions ---------------------------

function str = LocalUnitInfo(unit)
% Returns string capturing unit and transform info
if isempty(unit)
   str = '';
else
   str = sprintf(' (%s)',unit);
end