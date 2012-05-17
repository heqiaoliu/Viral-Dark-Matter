function parentName = ddg_get_parent_name(parent)

% Copyright 2002-2005 The MathWorks, Inc.

switch parent.class
    case 'Stateflow.Machine'
        parentName = '(machine) ';
    case 'Stateflow.Chart'
        parentName = '(chart) ';
    case 'Stateflow.EMChart'
        parentName = '(Embedded MATLAB) ';
    case 'Stateflow.TruthTableChart'
        parentName = '(truth table) ';
    case 'Stateflow.State'
        parentName = '(state) ';
    case 'Stateflow.Function'
        parentName = '(function) ';
    case 'Stateflow.EMFunction'
        parentName = '(Embedded MATLAB function) ';
    case 'Stateflow.TruthTable'
        parentName = '(truth table function) ';
    case 'Stateflow.Box'
        parentName = '(box) ';
    case 'Simulink.BlockDiagram'
        parentName = '(machine) ';
    otherwise
        parentName = sprintf('(#%s) ',parent.Name);
        warning('Stateflow:UnexpectedError','Bad parent type.');
end

parentName = [parentName parent.getFullName];
  