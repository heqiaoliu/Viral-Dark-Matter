function saveFilter(filName, filter)

%   Copyright 2010 The MathWorks, Inc.


covfilterName = 'coverageFilterRules';
if exist(filName , 'file')
    var = load(filName, '-mat');
end
%only one rule can be handeled by this editor
var.(covfilterName){1} = filter;
save(filName, '-struct', 'var');
