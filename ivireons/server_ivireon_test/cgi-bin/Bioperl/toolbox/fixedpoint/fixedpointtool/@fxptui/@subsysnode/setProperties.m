function [ok, errmsg] = setProperties(h, hdlg)
%SETMODELPROPERTIES   Set the ModelProperties.

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/05 22:16:59 $

ok = true;
errmsg = '';
try
	value = hdlg.getWidgetValue('cbo_log');
	h.daobject.MinMaxOverflowLogging = value;
        bd = get_param(h.getbdroot,'Object');
        if ~strcmpi(bd.SimulationMode,'Normal') && (~strcmpi(h.daobject.MinMaxOverflowLogging,'UseLocalSettings') && ~strcmpi(h.daobject.MinMaxOverflowLogging,'ForceOff'))
            BTN_TEST = h.PropertyBag.get('BTN_TEST');
            BTN_CHANGE_SIM_MODE = DAStudio.message('FixedPoint:fixedPointTool:btnChangeSimModeAndContinue');
            btn = fxptui.showdialog('instrumentationsimmodewarning', BTN_TEST);
            switch btn
              case BTN_CHANGE_SIM_MODE
                set(bd,'SimulationMode','normal');
              otherwise
            end
        end
        
catch e
	%if an invalid index is passed in don't set MinMaxOverflowLogging and
	%consume the error.
end

try
    % This setting is only applicable to the model - so change the model
    % setting.
    value = hdlg.getWidgetValue('cbo_arch');
    list = {'Overwrite','Merge'};
    rootModel = h.getbdroot;
    set_param(rootModel,'MinMaxOverflowArchiveMode',list{value+1});
catch e 
    %if an invalid value is passed in don't set MinMaxOverflowArchiveMode and
    %consume the error.
end

try
	value = hdlg.getWidgetValue('cbo_dt');
	h.daobject.DataTypeOverride = value;
catch e
	%if an invalid value is passed in don't set DataTypeOverride and
	%consume the error.
end

try
	value = hdlg.getWidgetValue('cbo_dt_appliesto');
	h.daobject.DataTypeOverrideAppliesTo = value;
catch e
	%if an invalid value is passed in don't set DataTypeOverride and
	%consume the error.
end


% [EOF]
