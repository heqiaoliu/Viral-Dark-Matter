function [isValid,errmsg,myStruct] = validOptimProblemStruct(myStruct,requiredFields,validValues)
%validOptimProblemStruct validates optimization problem structure.
%   Checks if 'myStruct' contains all the fields in the cell
%   array 'requiredFields'. To validate the values of 'requiredFields'
%   pass 'validValues'. The argument 'validValues' must be a nested cell
%   array of valid values. The output argument 'isValid' is a  boolean.
%
%   Example:
%
%    % Create a problem structure that has wrong value for 'solver' field
%      probStruct = struct('solver','fminx','options',optimset);
%    % Suppose requiredFields are 'solver' and 'options'
%    % Get valid solver names using createProblemStruct and assume options
%    % have no known valid values (any value is okay)
%      validValues = {fieldnames(createProblemStruct('solvers')), {} };
%    % Validate the structure 'probStruct'
%      [isValid,errmsg] = validProblem(probStruct,{'solver','options'},validValues)

%   Private to OPTIMTOOL

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/06/20 08:00:31 $


errmsg = '';
for i = 1:length(requiredFields)
    field = requiredFields{i};
    if strcmpi(field,'solver')
        % Old style GA and patternsearch structures will not have the
        % 'solver' field; add the 'solver' field.
        myStruct = fixMyStruct(myStruct);
    end
    % Check the field name is valid
    if ~ismember(field,fieldnames(myStruct))
        errmsg = [errmsg, sprintf('The input structure is missing the required field "%s".\n',field)];
        continue;
    end
    % Now check the values of the field
    okayValues = validValues{i};
    if isempty(okayValues) % no values to compare; valid values
        continue;
    else
        validValue = false;
        for j = 1:length(okayValues)  % check against valid values
            if isequal(myStruct.(field),okayValues{j})
                validValue = true;
                break;
            end
        end
        if ~validValue 
            errmsg = [errmsg, sprintf('The value for "%s" field is invalid.\n',field)];
        end
    end
end
myStruct = fixRNGFields(myStruct);
isValid = isempty(errmsg);

% After we validate the structure, we also make it consistent by using the
% compatible case-sensitive field names.

% Get the correct field names
probFields = fieldnames(createProblemStruct('all'));
myStructFields = fieldnames(myStruct);
[commonFields,index] = ismember(lower(myStructFields),lower(probFields));
% Modify a field name only if it present in myStruct
for i = 1:length(myStructFields)
    % If fields are not case-sensitive then make them
   if commonFields(i) && ~strcmp(myStructFields{i},probFields{index(i)})
      myStruct.(probFields{index(i)}) = myStruct.(myStructFields{i});
      myStruct = rmfield(myStruct,myStructFields{i});
   end
end
%--------------------------------------------
function fixedStruct = fixMyStruct(myStruct)
%fixMyStruct detects if the structure is an old style GA or patternsearch
%   problem structure and adds the 'solver' field to it. 

fixedStruct = myStruct;
if isfield(fixedStruct,'solver')
    return;
end
% Try to fix problem structure for GA
if all(ismember({'fitnessfcn','options'},fieldnames(myStruct)))
    fixedStruct.solver = 'ga';
% Try to fix problem structure for patternsearch
elseif all(ismember({'objective','options'},fieldnames(myStruct))) && ...
        ismember('PollMethod',fieldnames(myStruct.options))
    fixedStruct.solver = 'patternsearch';
end

%--------------------------------------------
function fixedStruct = fixRNGFields(myStruct)
%fixRNGFields detects if the structure has old style randstate and randnstate
%   fields, and converts them to rngstate.

fixedStruct = myStruct;
if isfield(myStruct,'randstate') && isfield(myStruct,'randnstate')
    warning('optim:validOptimProblemStruct:DeprecatedRNGFields', ...
            ['The input structure uses the deprecated "randstate" and "randnstate" fields.\n' ...
             'Converting to use the "rngstate" field.']);
    if isempty(myStruct.randstate) && isempty(myStruct.randnstate)
        fixedStruct.rngstate = [];
    elseif isa(myStruct.randstate, 'uint32') && isequal(size(myStruct.randstate),[625, 1]) && ...
           isa(myStruct.randnstate, 'double') && isequal(size(myStruct.randnstate),[2, 1])
        % Save the default stream.  Since we'll be messing with the legacy
        % generators, we have to also save the default stream's state if it
        % is the legacy stream.
        dflt = RandStream.getDefaultStream;
        if strcmpi(dflt.Type, 'legacy'), legacyState = dflt.State; end
        % Use the randstate and randnstate fields to set the old generators directly.
        warnState = warning('off','MATLAB:RandStream:ActivatingLegacyGenerators');
        try
            rand('twister',myStruct.randstate);
            randn('state',myStruct.randnstate);
        catch
            error('optim:validOptimProblemStruct:InvalidRNGFields', ...
                  'The input structure contains invalid values for the "randstate" and "randnstate" fields.');
        end
        warning(warnState);
        % Create the new rngstate field based on the legacy stream's (combined) state.
        legacy = RandStream.getDefaultStream;
        fixedStruct.rngstate = struct('state',{legacy.State}, 'type',{legacy.Type});
        % Put the default stream back the way it was.
        RandStream.setDefaultStream(dflt);
        if strcmpi(dflt.Type, 'legacy'), dflt.State = legacyState; end

    else
        error('optim:validOptimProblemStruct:InvalidRNGFields', ...
              'The input structure contains invalid values for the "randstate" and "randnstate" fields.');
    end
    % Remove the old fields from the structure.
    fixedStruct = rmfield(fixedStruct,{'randstate' 'randnstate'});
end
