function data = getInspectorSummary(this,Name)
% Get a formatted html display for the selected block

data = {'<font face="monospaced"; size=3>'};

blocklink = sprintf('<a href="block:%s">%s</a>',this.FullBlockName,Name);
data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:LinearizationForBlock',blocklink);

data{end+1} = '';
if any(strcmp(this.inLinearizationPath,{'Yes','N/A'}))
    data = localParseCharArray(evalc('display(this.SystemData)'),data);
else
    data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockNotInLinearizationPath');
end
data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockLinearizationSpecifiedByUser');

%% LocalFunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalParseCharArray - parses to convert char array with carriage returns
%  to create cell array.
function data = localParseCharArray(strin,data)

% Find the carriage returns
ind = regexp(strin,'\n');

% Loop over every line
for ct = 1:length(ind);
    if ct == 1
        data{end+1} = sprintf('<A>%s</A>',regexprep(strin(1:ind(ct)),' ','&nbsp;'));
    else
        data{end+1} = sprintf('<A>%s</A>',regexprep(strin(ind(ct-1):ind(ct)),' ','&nbsp;'));
    end
end