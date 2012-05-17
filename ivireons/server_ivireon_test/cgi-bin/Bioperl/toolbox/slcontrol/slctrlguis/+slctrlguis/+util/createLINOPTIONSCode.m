function optcell = createLINOPTIONSCode(opt,mode)
% CREATELINOPTIONSCODE
%
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/12/29 02:19:50 $

opt_default = linoptions;

if strcmp(mode,'Linearization')
    % Get the general linearization options
    names = getOptionsCategories(opt,'GenericLinearization');
    inarg = getInputArgs(names,opt,opt_default);
    
    % Get the algorithm specific options
    if strcmp(opt.LinearizationAlgorithm,'blockbyblock')
        names = getOptionsCategories(opt,'BlockByBlockLinearization');        
    else
        names = getOptionsCategories(opt,'NumericalPerturbLinearization');
    end
    inarg = [inarg,getInputArgs(names,opt,opt_default)];
else
    names = getOptionsCategories(opt,'OperatingPointSearch');
    names(strcmp(names,'OptimizationOptions')) = [];
    inarg = getInputArgs(names,opt,opt_default);
end

optcell = '';
if numel(inarg) > 0
    optcell{end+1} = ctrlMsgUtils.message('Slcontrol:matlabcodegen:LINOPTIONSOptionsComment');
    if numel(inarg) == 1
        optcell{end+1} = sprintf('opt = linoptions(%s);',inarg{1});
    elseif numel(inarg) > 1
        optcell{end+1} = sprintf('opt = linoptions(%s,...',inarg{1});
        for ct = 2:(numel(inarg)-1)
            optcell{end+1} = sprintf('                 %s,...',inarg{ct});
        end
        optcell{end+1} = sprintf('                 %s);',inarg{end});
    end
end

% Create optimization options
if strcmp(mode,'OperatingPointSearch')
    opt_default.OptimizerType = opt.OptimizerType;
    fnames = fieldnames(opt.OptimizationOptions);
    for ct = 1:numel(fnames)
        if ~isequal(opt.OptimizationOptions.(fnames{ct}),opt_default.OptimizationOptions.(fnames{ct}))
            prop = opt.OptimizationOptions.(fnames{ct});
            if ischar(prop)
                optcell{end+1} = sprintf('opt.OptimizationOptions.%s = %s;',fnames{ct},prop);
            else
                optcell{end+1} = sprintf('opt.OptimizationOptions.%s = %d;',fnames{ct},prop);
            end
        end
    end
end

%% 
function inarg = getInputArgs(names,opt,opt_default)
inarg = {};
for ct = 1:numel(names)
    prop = opt.(names{ct});
    if ~isequal(opt_default.(names{ct}),prop)
        if ischar(prop)
            inarg{end+1} = sprintf('''%s'',''%s''',names{ct},prop);
        else
            inarg{end+1} = sprintf('''%s'',%d',names{ct},prop);
        end            
    end
end