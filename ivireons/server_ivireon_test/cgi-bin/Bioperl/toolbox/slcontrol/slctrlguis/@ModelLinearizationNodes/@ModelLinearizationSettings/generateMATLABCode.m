function str = generateMATLABCode(this) 
% GENERATEMATLABCODE  
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/29 02:19:52 $

% Get the model
model = this.Model;

% Create the string to be written
str = {};

% Get the operating point code gen info
[op,op_type] = getSelectedOperatingPointsMATLABCode(this);

% Create the function signature
if strcmp(op_type,'selected_operating_points')
    str{end+1} = 'function sys = mylinearizemodel(op)';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeModelH1',model);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeModelDescriptionExternalOperatingPoint',model);
elseif strcmp(op_type,'model_initial_condition')
    str{end+1} = 'function sys = mylinearizemodel';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeModelH1',model);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeModelDescriptionIC',model);
else
    str{end+1} = 'function sys = mylinearizemodel';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeModelH1',model);
    str{end+1} = '%';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizeModelDescriptionSnapshot',model);
end

% Generate the header
str{end+1} = '';
str = [str,slctrlguis.util.createVerDateCode];

% Specify the model
str{end+1} = '';
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SpecifyModelName');
str{end+1} = sprintf('model = ''%s'';',model);

% Create the linearization IOs
iostr = getLinearizationIOGenCode(this);
if numel(iostr) == 1
    io_arg = '';
else
    str{end+1} = '';
    io_arg = ',ios';
    str = [str,iostr];
end

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
str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:ModelLinearizationComment');

% Create the function signature
if strcmp(op_type,'selected_operating_points')
    str{end+1} = sprintf('sys = linearize(model,op%s%s);',io_arg,opt_arg);
elseif strcmp(op_type,'simulation_snapshots')
    op = mat2str(GenericLinearizationNodes.evalSnapshotVector(op));
    str{end+1} = sprintf('sys = linearize(model,%s%s%s);',op,io_arg,opt_arg);
else
    str{end+1} = sprintf('sys = linearize(model%s%s);',io_arg,opt_arg);
end

% Create the plot command
if ~strcmp(this.LTIPlotType,'None')
    str{end+1} = '';
    str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearModelPlotComment');
    str{end+1} = sprintf('%s(sys)',this.LTIPlotType);
end

%%
function iocell = getLinearizationIOGenCode(this)

iocell = {};
iocell{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LinearizationIOComment',this.Model);
if strcmp(this.getOpCondNode.Options.LinearizationAlgorithm,'blockbyblock')
    % Remove the linearization IOs that are not active
    IOData = this.IOData(strcmp(get(this.IOData,'Active'),'on'));
    liniostr = 'ios(%d) = linio(''%s'',%d,''%s'');';
    liniostr_ol = 'ios(%d) = linio(''%s'',%d,''%s'',''%s'');';
    for ct = numel(IOData):-1:1
        if strcmp(IOData(ct).OpenLoop,'on')
            iocell{end+1} = sprintf(liniostr_ol,ct,IOData(ct).Block,...
                IOData(ct).PortNumber,IOData(ct).Type,IOData(ct).OpenLoop);
        else
            iocell{end+1} = sprintf(liniostr,ct,IOData(ct).Block,...
                IOData(ct).PortNumber,IOData(ct).Type);
        end
    end
end

