function [allProps, allValues, configurationName] = pConvertToPVArraysWithConfig(args, sectionName)
%pConvertToPVArrays Use configurations when convert a variable argument list
%into cell arrays of properties and values.
%  The function is identical to convertToPVArrays, except for the following:
%  - The argument list that should be processed is passed as the first argument.
%  - The optional second argument is the section name of the configuration.  If
%  that provided, we replace all instances of 'Configuration', 'configName'
%  param-value pairs with the param-value pairs found in the sectionName section
%  of the 'configName' configuration.

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2010/02/25 08:02:23 $

error(nargchk(1, 2, nargin, 'struct'));
processConfigurations = (nargin > 1);

if ~iscell(args)
    error('distcomp:distcomppvparser:invalidInput', ...
          'First argument must be a cell array.');
end
[allProps, allValues] = parallel.internal.convertToPVArrays(args{:});
configurationName = '';
if processConfigurations
    ind = find(strcmpi(allProps, 'Configuration'), 1);
    while ~isempty(ind)
        configurationName = allValues{ind};
        conf = distcompConfigSection(configurationName, sectionName);
        p = fieldnames(conf);
        v = struct2cell(conf);
        allProps = {allProps{1:ind-1}, p{:}, allProps{ind + 1: end}};
        allValues = {allValues{1:ind-1}, v{:}, allValues{ind + 1: end}};
        ind = find(strcmpi(allProps, 'Configuration'), 1);
    end
end
