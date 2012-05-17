function varargout = separateOptimStruct(myStruct)
% SEPARATEOPTIMSTRUCT takes a problem structure and returns individual fields of
%   the structure to the caller. The caller (always a solver) information is 
%   found from the 'solver' field in 'myStruct'.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/10/08 17:14:56 $

% Determine the caller name; Make sure that the problem structure is valid
callStack = dbstack;
caller = callStack(2).file(1:end-2);
requiredFields = {'solver','options'};
validValues = {fieldnames(createProblemStruct('solvers')), {} };
[validProblemStruct,errmsg,myStruct] = validOptimProblemStruct(myStruct,requiredFields,validValues);

if validProblemStruct
    solver = myStruct.solver;
else
    error('MATLAB:separateOptimStruct:InvalidStructInput','Invalid problem structure: %s',errmsg);
end
% Make sure that 'solver' is same as the caller
if ~strcmpi(caller,solver)
    error('MATLAB:separateOptimStruct:InvalidSolver','Use %s function for this problem structure.',upper(solver));
end
options = myStruct.options; % Take out options field
myStruct = createProblemStruct(solver,[],myStruct); % Second argument is required but can be []
probFieldNames = fieldnames(myStruct);
% Extract values of all the fields
for i = 1:length(probFieldNames) - 1 % Last field is the 'solver' field
    varargout{i} = myStruct.(probFieldNames{i});
end
varargout{end+1} = options; % Stuff options as the last field
