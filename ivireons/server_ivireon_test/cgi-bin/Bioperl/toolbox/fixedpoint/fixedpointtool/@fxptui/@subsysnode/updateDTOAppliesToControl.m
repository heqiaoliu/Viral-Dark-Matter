function updateDTOAppliesToControl(h, hdlg)
%UPDATEDTOAPPLIESTOCONTROL Updates the visibility of the data types to
%override widget.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:17:00 $


dto_value = hdlg.getWidgetValue('cbo_dt');
switch dto_value
    case 0
        dto_str = 'UseLocalSettings';
    case 1
        dto_str = 'ScaledDouble';
    case 2
        dto_str = 'Double';
    case 3
        dto_str = 'Single';
    case 4
        dto_str = 'Off';
    otherwise
        dto_str = 'UseLocalSettings';
end
vis = ~ismember(dto_str,{'UseLocalSettings','Off'});
setVisible(hdlg,'cbo_dt_appliesto',vis);

% [EOF]
