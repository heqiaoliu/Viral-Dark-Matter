function str = generateMATLABCode(this) 
% GENERATEMATLABCODE  
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/29 02:19:51 $

% Check to make sure that the block-by-block option is selected
if strcmp(this.getOpCondNode.Options.LinearizationAlgorithm,'numericalpert')
    ctrlMsgUtils.error('Slcontrol:linearizationtask:PerturbationNotValidBlockLinearization');
end

% Get the model
model = this.Model;
block = removeNewLine(slcontrol.Utilities,this.Block);
blockname = removeNewLine(slcontrol.Utilities,get_param(this.Block,'Name'));

% Create the string to be written
str = {};

% Get the operating point code gen info
[op,op_type] = getSelectedOperatingPointsMATLABCode(this);

% Create the function signature
if strcmp(op_type,'selected_operating_points')
    str{end+1} = 'function sys = mylinearizeblock(op)';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeBlockH1',blockname);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeBlockDescriptionExternalOperatingPoint',blockname);
elseif strcmp(op_type,'model_initial_condition')
    str{end+1} = 'function sys = mylinearizeblock';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeBlockH1',blockname);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeBlockDescriptionIC',blockname);
else
    str{end+1} = 'function sys = mylinearizeblock';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeBlockH1',blockname);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeBlockDescriptionSnapshot',blockname);
end

% Generate the header
str{end+1} = '';
str = [str,slctrlguis.util.createVerDateCode];

% Specify the model
str{end+1} = '';
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SpecifyModelName');
str{end+1} = sprintf('model = ''%s'';',model);

% Create the linearization options
optionscode = slctrlguis.util.createLINOPTIONSCode(this.getOpCondNode.Options,'Linearization');
if ~isempty(optionscode)
    str{end+1} = '';
    str = [str,optionscode];
    opt_arg = ',opt';
else
    opt_arg = '';
end

% Create the linearize command 
str{end+1} = '';
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:BlockLinearizationComment');

% Create the function signature
if strcmp(op_type,'selected_operating_points')
    str{end+1} = sprintf('sys = linearize(model,op,''%s''%s);',block,opt_arg);
elseif strcmp(op_type,'simulation_snapshots')
    op = mat2str(GenericLinearizationNodes.evalSnapshotVector(op));
    str{end+1} = sprintf('sys = linearize(model,%s,''%s''%s);',op,block,opt_arg);
else
    str{end+1} = sprintf('sys = linearize(model,''%s''%s);',block,opt_arg);
end

% Create the plot command
if ~strcmp(this.LTIPlotType,'None')
    str{end+1} = '';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearModelPlotComment');
    str{end+1} = sprintf('%s(sys)',this.LTIPlotType);
end