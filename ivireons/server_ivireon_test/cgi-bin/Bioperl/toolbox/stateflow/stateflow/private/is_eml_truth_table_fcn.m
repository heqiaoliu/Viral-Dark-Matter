function result = is_eml_truth_table_fcn(id)

% Copyright 2004-2005 The MathWorks, Inc.

result = ~isempty(sf('find',id,'state.type','FUNC_STATE', ...
                               'state.truthTable.isTruthTable',1, ...
                               'state.truthTable.useEML',1));

return;
