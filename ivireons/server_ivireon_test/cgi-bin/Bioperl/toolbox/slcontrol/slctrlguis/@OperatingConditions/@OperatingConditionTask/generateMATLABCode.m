function str = generateMATLABCode(this) 
% GENERATEMATLABCODE  
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/12/07 20:49:02 $

% Validate that the operating point specification is in sync with the
% model.  An error will be thrown which is caught in the caller function.
update(this.OpSpecData,true);

% Get the model
model = this.Model;

% Create the string to be written
str = {};

% Get the operating point code gen info
[op_str,op_type] = getSelectedOperatingPointsMATLABCode(this);

% Create the function signature
if strcmp(op_type,'operating_point_search')
    str{end+1} = 'function [op, opreport] = myoperatingpointsearch';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:OperatingPointSearchH1',model);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:OperatingPointSearchDescription');
else
    str{end+1} = 'function op = myoperatingpointsnapshot';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:OperatingPointSnapshotH1',model);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:OperatingPointSnapshotDescription',model);
end

% Generate the header
str{end+1} = '';
str = [str,slctrlguis.util.createVerDateCode];

% Specify the model
str{end+1} = '';
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SpecifyModelName');
str{end+1} = sprintf('model = ''%s'';',model);

% Add operating point code
str{end+1} = '';
str = [str,op_str];
