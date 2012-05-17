% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $

function export(etm, cs, filename, argName, argValue)
if nargin < 2 || ~isa(cs, 'Simulink.ConfigSet') || ~isa(filename, 'char')
    return;
else
    etm.csCopyFrom = cs;
    etm.filename = filename;
end

format = 'MATLAB function';
noComment = false;
variableName = 'cs';
update = false;
timestamp = true;
encoding = true;

for i=1:length(argName)
    if isempty(argName{i})
        continue;
    end

    switch lower(argName{i})
      case {'-format'}
        format = argValue{i};
      case {'-varname'}
        variableName = argValue{i};
      case {'-update'}
        if strcmpi(argValue{i}, 'true')
            update = true;
        else
            update = false;
        end
      case {'-timestamp'}
        if strcmpi(argValue{i}, 'on')
            timestamp = true;
        else
            timestamp = false;
        end
      case {'-comments'}     % for testibility only
        if strcmpi(argValue{i}, 'on')
            noComment = false;
        else
            noComment = true;
        end
      case {'-encoding'}     % for testibility only
        if strcmpi(argValue{i}, 'on')
            encoding = true;
        else
            encoding = false;
        end
    end
end

etm.initialize(format);
etm.populateConfigSetPane(noComment);
etm.printed = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
etm.variableName = variableName;
etm.constructCSP();
etm.preprocess(noComment);
etm.generate(update, noComment, timestamp, encoding);

end
