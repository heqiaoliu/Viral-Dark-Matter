function moveresults(h, fromrun, torun)
%MOVERESULTS moves results from FROMRUN to TORUN

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/05/14 16:54:13 $

error(nargchk(3,3,nargin));
ds = h.getdataset;
% make the variable persistent to improve performance.
persistent btn_yes;
if isempty(btn_yes)
    btn_yes = DAStudio.message('FixedPoint:fixedPointTool:labelYes');
end
btn = btn_yes;
%turn property change listeners off while we update the properties of
%displayed data. (prevent flickering)
h.sleep;
if(isempty(ds) || isempty(ds.getresults(fromrun)))
  return;
end
BTN_TEST = h.PropertyBag.get('BTN_TEST');
if isequal(torun,1) && ~isempty(ds.getresults(torun))
    btn = fxptui.showdialog('overwriteresultsReference',BTN_TEST);
elseif isequal(torun,0) && ~isempty(ds.getresults(torun))
    btn = fxptui.showdialog('overwriteresultsActive',BTN_TEST);
end

%clear the EDT before so the button state gets set before we read it on the
%MATLAB thread
drawnow;
switch btn
  case btn_yes
    ds.move(fromrun,torun);
  otherwise
end
h.getRoot.firehierarchychanged;
h.updatedata;
h.updateactions;
%turn property change listeners back on after we update the properties of
%displayed data. (prevent flickering)
h.wake;

% [EOF]
