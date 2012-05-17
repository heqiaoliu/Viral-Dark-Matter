function res = checkfis(fis);

% Copyright 2005 The MathWorks, Inc.

%CHECKFIS Checks the fuzzy inference system properties for legal values.
%
% res = CHECKFIS(FIS) returns 1 if all properties have legal values else it
% throws an error.
%

for i =1:1:length(fis.rule)
    if isempty(fis.rule(i).weight)
        ermsg = sprintf('weight of rule %d is empty.',i);
        error(ermsg);        
    end
    if isempty(fis.rule(i).antecedent)
        ermsg = sprintf('antecedent of rule %d is empty.',i);
        error(ermsg);        
    end
    if isempty(fis.rule(i).consequent)
        ermsg = sprintf('consequent of rule %d is empty.',i);
        error(ermsg);        
    end
    if isempty(fis.rule(i).connection)
        ermsg = sprintf('connection of rule %d is empty.',i);
        error(ermsg);
    end
end

for i=1:1:length(fis.input)
    if isempty(fis.input(i).name)
        ermsg = sprintf('name of input %d is empty.',i);
        error(ermsg);
    end
    if isempty(fis.input(i).range)
        ermsg = sprintf('range of input %d is empty.',i);
        error(ermsg);       
    end
end

for i=1:1:length(fis.output)
    if isempty(fis.output(i).name)
        ermsg = sprintf('name of output %d is empty.',i);
        error(ermsg);
    end
    if isempty(fis.output(i).range)
        ermsg = sprintf('range of output %d is empty.',i);
        error(ermsg);       
    end
end

res = 1;