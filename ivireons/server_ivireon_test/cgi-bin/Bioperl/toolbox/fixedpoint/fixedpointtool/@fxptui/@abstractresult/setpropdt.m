function val = setpropdt(h, val)
%SETPROPFL   Set the propdt.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:18:44 $

% Make the variables persistent to improve performance.
persistent BTN_CHANGE_ALL;
persistent BTN_CHANGE_THIS;

%There is no ProposedDT for this result
if(isempty(val) || isequal('n/a', val))
  h.ProposedMin = [];
  h.ProposedMax = [];
  return;
end
%cache the old value incase we need to revert
oldval = h.ProposedDT;
%make sure the new value is of  the correct form and evals
if any(regexp(val, 'fixdt'))
  %the form appears correct so try to eval it
  try
    proposedDataType = eval(val);
  catch fpt_exception
    %did not eval -> warn
    fxptui.showdialog('proposedtinvalid', val);
    val = oldval;
    return;
  end
else
  %did not contain 'fixdt' string -> warn
  fxptui.showdialog('proposedtinvalid', val);
  val = oldval;
  return;
end
%warn if we're changing a shared data type
if(~isempty(h.DTGroup))
  mdl = h.getbdroot;
  appdata = SimulinkFixedPoint.getApplicationData(mdl);
  %don't warn if we're in the process of proposing
  if(~appdata.inScaling)
      BTN_TEST = h.PropertyBag.get('BTN_TEST');
      if isempty(BTN_CHANGE_ALL)
          BTN_CHANGE_ALL = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeAll');
      end
      if isempty(BTN_CHANGE_THIS)
          BTN_CHANGE_THIS = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeThis');
      end
      btn = fxptui.showdialog('proposedtsharedwarning', BTN_TEST);
      if ~isempty(btn)
          switch btn
            case BTN_CHANGE_ALL
              h.PropertyBag.put('DTGROUP_CHANGE_SCOPE', BTN_CHANGE_ALL);
            case BTN_CHANGE_THIS
              h.PropertyBag.put('DTGROUP_CHANGE_SCOPE', BTN_CHANGE_THIS);
            otherwise
              %this is the cancel case. revert to old value
              val = oldval;
              return;
          end
      end
  end
end

% [EOF]
