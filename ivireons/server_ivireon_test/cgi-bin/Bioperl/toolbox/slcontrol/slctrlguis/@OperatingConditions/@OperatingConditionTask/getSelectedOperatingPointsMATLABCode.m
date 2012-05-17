function [op_str,op_type] = getSelectedOperatingPointsMATLABCode(this)
% GETSELECTEDOPERATINGPOINTSMATLABCODE

% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/01/20 15:48:48 $

% Find the mode that the operating conditions panel is in
model = this.Model;

if (this.Handles.OpCondSpecPanel.OpCondComputeCombo.getSelectedIndex == 0)
    op_str = LocalCreateOpSearchCode(this,model);
    op_type = 'operating_point_search';
else
    op_str = LocalCreateOpSnapshotCode(this);
    op_type = 'simulation_snapshot';
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function op_str = LocalCreateOpSnapshotCode(this)

% Get the settings node and its dialog interface
di = this.Handles.OpCondSpecPanel;
SnapShotTimes_str = char(di.SimLinearizationPanel.getSnapshotTimesTextField.getText);

try
    temp = evalin('base',SnapShotTimes_str);
catch Ex
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidSnapshotTimes')
end

% Create the simulation snapshot code
op_str{1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:RunSimulationComputeSnapshots');

if isempty(str2num(SnapShotTimes_str)) %#ok<ST2NM>
    op_str{end+1} = sprintf('op = findop(model,''%s'');',SnapShotTimes_str);
else
    op_str{end+1} = sprintf('op = findop(model,%s);',SnapShotTimes_str);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function op_str = LocalCreateOpSearchCode(this,model)

% Update the operating condition object
op_gui = EvalOperSpecForms(this);

% Create the operating point specification object
op_str{1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:CreateSpecificationObject');
op_str{2} = 'opspec = operspec(model);';

% Get the reference operating point specification
opspec = operspec(model);

% Loop over the states
op_str{end+1} = '';
if numel(op_gui.States)
    op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SetStateConstraintsComment1');
    op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SetStateConstraintsComment2');
    op_str{end+1} = '';
    for state_ct = 1:numel(opspec.States)    
        State = op_gui.States(state_ct);
        blk = removeNewLine(slcontrol.Utilities,State.Block);
        op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:StateConstraintLabel',state_ct,blk);
        if any(State.x ~= opspec.States(state_ct).x)
            op_str{end+1} = sprintf('opspec.States(%d).x = %s;',state_ct,mat2str(State.x));
        else
            op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:DefaultSettingsAreUsed');
        end
        if any(State.Known ~= opspec.States(state_ct).Known)
            op_str{end+1} = sprintf('opspec.States(%d).Known = %s;',state_ct,mat2str(State.Known));
        end
        if any(State.SteadyState ~= opspec.States(state_ct).SteadyState)
            op_str{end+1} = sprintf('opspec.States(%d).SteadyState = %s;',state_ct,mat2str(State.SteadyState));
        end        
        if any(State.Min ~= opspec.States(state_ct).Min)
            op_str{end+1} = sprintf('opspec.States(%d).Min = %s;',state_ct,mat2str(State.Min));
        end
        if any(State.Max ~= opspec.States(state_ct).Max)
            op_str{end+1} = sprintf('opspec.States(%d).Max = %s;',state_ct,mat2str(State.Max));
        end
        op_str{end+1} = '';
    end
end

if numel(op_gui.Inputs)
    op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SetInputConstraintsComment1');
    op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SetInputConstraintsComment2');
    op_str{end+1} = '';
    for input_ct = 1:numel(opspec.Inputs)
        Input = op_gui.Inputs(input_ct);
        blk = removeNewLine(slcontrol.Utilities,Input.Block);
        op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:InputConstraintLabel',input_ct,blk);
        if any(Input.u ~= opspec.Inputs(input_ct).u)
            op_str{end+1} = sprintf('opspec.Inputs(%d).u = %s;',input_ct,mat2str(Input.u));
        else
            op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:DefaultSettingsAreUsed');
        end
        if any(Input.Known ~= opspec.Inputs(input_ct).Known)
            op_str{end+1} = sprintf('opspec.Inputs(%d).Known = %s;',input_ct,mat2str(Input.Known));
        end
        if any(Input.Min ~= opspec.Inputs(input_ct).Min)
            op_str{end+1} = sprintf('opspec.Inputs(%d).Min = %s;',input_ct,mat2str(Input.Min));
        end
        if any(Input.Max ~= opspec.Inputs(input_ct).Max)
            op_str{end+1} = sprintf('opspec.Inputs(%d).Max = %s;',input_ct,mat2str(Input.Max));
        end
        op_str{end+1} = '';
    end
end

if numel(op_gui.Outputs)
    op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SetOutputConstraintsComment1');
    op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:SetOutputConstraintsComment2');
    op_str{end+1} = '';
    OutputNames = get(opspec.Outputs,'Block');    
    for output_ct = 1:numel(op_gui.Outputs)
        Output = op_gui.Outputs(output_ct);
        if ~any(strcmp(op_gui.Outputs(output_ct).Block,OutputNames))
            op_str{end+1} = '%% Add an output specification.';
            op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:AddOutputSpecification');
            op_str{end+1} = sprintf('opspec = addoutputspec(''%s'',%s);',Output.Block,num2str(Output.PortNumber));
        end
        blk = removeNewLine(slcontrol.Utilities,Output.Block);
        op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:OutputConstraintLabel',output_ct,blk);
        if any(Output.y ~= opspec.Outputs(output_ct).y)
            op_str{end+1} = sprintf('opspec.Outputs(%d).y = %s;',output_ct,mat2str(Output.y));
        else
            op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:DefaultSettingsAreUsed');
        end
        if any(Output.Known ~= opspec.Outputs(output_ct).Known)
            op_str{end+1} = sprintf('opspec.Outputs(%d).Known = %s;',output_ct,mat2str(Output.Known));
        end
        if any(Output.Min ~= opspec.Outputs(output_ct).Min)
            op_str{end+1} = sprintf('opspec.Outputs(%d).Min = %s;',output_ct,mat2str(Output.Min));
        end
        if any(Output.Max ~= opspec.Outputs(output_ct).Max)
            op_str{end+1} = sprintf('opspec.Outputs(%d).Max = %s;',output_ct,mat2str(Output.Max));
        end
        op_str{end+1} = '';
    end
end

% Create the linearization options
options = evalOptimOptions(this);
optionscode = slctrlguis.util.createLINOPTIONSCode(options,'OperatingPointSearch');
if ~isempty(optionscode)
    op_str = [op_str,optionscode];
    opt_arg = ',opt';
else
    opt_arg = '';
end

% Create the findop command
op_str{end+1} = '';
op_str{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:PerformOperatingPointSearch');

% Create the function signature
if isempty(opt_arg)
    op_str{end+1} = sprintf('[op,opreport] = findop(model,opspec);');
else    
    op_str{end+1} = sprintf('[op,opreport] = findop(model,opspec,opt);');
end