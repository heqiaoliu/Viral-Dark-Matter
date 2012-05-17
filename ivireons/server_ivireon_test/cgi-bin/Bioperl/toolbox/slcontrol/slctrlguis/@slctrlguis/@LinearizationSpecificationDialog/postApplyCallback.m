function [status,errMsg] = postApplyCallback(this)
% postApplyCallback

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:25 $

% Initialize the error status
status = true;
errMsg = '';

% Parse the data
SCDBlockLinearizationSpecification = this.Data.SCDBlockLinearizationSpecification;
% Fill in the parameter name/value data
PNPVTableData = this.Data.PNPVTableData;
% Eliminate rows without entries
for ct = size(PNPVTableData,1):-1:1
    if isempty(PNPVTableData{ct,1}) && isempty(PNPVTableData{ct,2})
        PNPVTableData(ct,:) = [];
    elseif isempty(PNPVTableData{ct,1}) || isempty(PNPVTableData{ct,2})
        [errMsg,status] = getMessageForErrorDialog(this,'Slcontrol:blockspecificationdlg:ParameterNameValuePairNotComplete');
        return
    end
end
if ~isempty(PNPVTableData)
    if size(PNPVTableData,1) == 1
        SCDBlockLinearizationSpecification.ParameterNames = PNPVTableData{1,1};
        SCDBlockLinearizationSpecification.ParameterValues = PNPVTableData{1,2};
    else
        PNstr = [sprintf('%s,',PNPVTableData{1:end-1,1}),PNPVTableData{end,1}];
        PVstr = [sprintf('%s,',PNPVTableData{1:end-1,2}),PNPVTableData{end,2}];
        SCDBlockLinearizationSpecification.ParameterNames = PNstr;
        SCDBlockLinearizationSpecification.ParameterValues = PVstr;
    end
else
    SCDBlockLinearizationSpecification.ParameterNames = '';
    SCDBlockLinearizationSpecification.ParameterValues = '';
end

this.Data.SCDBlockLinearizationSpecification = SCDBlockLinearizationSpecification;

% Set the block properties
set_param(this.Block,'SCDBlockLinearizationSpecification',SCDBlockLinearizationSpecification)
set_param(this.Block,'SCDEnableBlockLinearizationSpecification',this.Data.SCDEnableBlockLinearizationSpecification)

end