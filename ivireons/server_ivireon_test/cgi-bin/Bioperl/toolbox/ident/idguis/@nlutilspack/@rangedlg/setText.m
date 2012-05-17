function str = setText(this)
%Set instruction string that goes above the edit box in the dialog
% Also set the dialog name.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:55 $

switch lower(this.Type)
    case 'time'
        str = 'Set time span (in TimeUnits) for transient response:';
        name = 'Time Range';
    case 'frequency'
        str = 'Enter row vector with frequency values (rad/TimeUnits):';
        name = 'Frequency Range';
    case 'nonlinear'
        str = 'Specify range for input to nonlinear block ([min, max]):';
        name = 'Range for Input to Nonlinearity';
    case 'samples'
        str = 'Specify number of samples to use for each regressor:';
        name = 'Regressor Samples';
    otherwise
        ctrlMsgUtils.error('Ident:idguis:rangedlgWrongPlotType')
end

set(this.UIs.TopLabel,'String',str);
set(this.Dialog,'Name',name,'Tag',name);
