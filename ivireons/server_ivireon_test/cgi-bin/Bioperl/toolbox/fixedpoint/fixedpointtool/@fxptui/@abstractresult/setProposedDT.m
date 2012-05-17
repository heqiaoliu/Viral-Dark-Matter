function setProposedDT(h)
%SETPROPOSEDDT   Set the propdt.

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/02/25 08:03:49 $

%There is no ProposedDT for this result
if(isempty(h.ProposedDT) || isequal('n/a', h.ProposedDT))
  h.ProposedMin = [];
  h.ProposedMax = [];
  return;
end

mdl = h.getbdroot;
appdata = SimulinkFixedPoint.getApplicationData(mdl);
% make the variables persistent to improve performance.
persistent BTN_CHANGE_ALL;
persistent BTN_CHANGE_THIS;
if isempty(BTN_CHANGE_ALL)
    BTN_CHANGE_ALL = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeAll');
end
if isempty(BTN_CHANGE_THIS)
    BTN_CHANGE_THIS = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeThis');
end
btn = h.PropertyBag.get('DTGROUP_CHANGE_SCOPE');
if ~isempty(btn)
    switch btn
      case BTN_CHANGE_ALL
        setpropdt4group(h, appdata);
        h.PropertyBag.put('DTGROUP_CHANGE_SCOPE', BTN_CHANGE_THIS);    
      case BTN_CHANGE_THIS
        %drop through and set ProposedDT on this result
      otherwise
        return;
    end
end

% Turn on the checkbox if the specifiedDT and proposedDT are different.
h.Accept = ~strcmpi(h.SpecifiedDT,h.ProposedDT);

if ~isempty(h.DTGroup)
    sharedMinMax = SimulinkFixedPoint.Autoscaler.collectDTGSharedInfo(appdata, h.DTGroup);
    run = fxptui.str2run(h.Run);
    results = appdata.dataset.getlist4id(run, h.DTGroup);
    for i = 1:numel(results)
        results(i).Alert = SimulinkFixedPoint.Autoscaler.determineAlertLevelFromResult(results(i), appdata, sharedMinMax);
    end
else
    sharedMinMax = [];
    h.Alert = SimulinkFixedPoint.Autoscaler.determineAlertLevelFromResult(h, appdata, sharedMinMax);
end

%--------------------------------------------------------------------------
function setpropdt4group(h, appdata)
run = fxptui.str2run(h.Run);
results = appdata.dataset.getlist4id(run, h.DTGroup);
appdata.inScaling = true;
for idx = 1:numel(results)
  try
    if(~isequal(results(idx), h))
      results(idx).ProposedDT = h.ProposedDT;
    end
  catch %#ok
    appdata.inScaling = false;
  end
end
appdata.inScaling = false;

% [EOF]
