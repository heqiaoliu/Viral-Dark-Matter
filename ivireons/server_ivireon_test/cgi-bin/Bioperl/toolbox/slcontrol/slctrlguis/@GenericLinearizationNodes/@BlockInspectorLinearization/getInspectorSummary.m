function data = getInspectorSummary(this,Name)
% Get a formatted html display for the selected block

data = {'<font face="monospaced"; size=3>'};

blocklink = sprintf('<a href="block:%s">%s</a>',this.FullBlockName,Name);
data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:LinearizationForBlock',blocklink);
data{end+1} = '';
if ~isempty(this.A) && strcmp(this.inLinearizationPath,'Yes')
    data{end+1} = 'a = ';
    data = LocalCreateMatrixData(this.A,data);
    data{end+1} = 'b = ';
    data = LocalCreateMatrixData(this.B,data);
    data{end+1} = 'c = ';
    data = LocalCreateMatrixData(this.C,data);
    data{end+1} = 'd = ';
    data = LocalCreateMatrixData(this.D,data);
    data{end+1} = 'Ts = ';
    data = LocalCreateMatrixData(this.SampleTimes,data);
elseif strcmp(this.inLinearizationPath,'Yes')
    data{end+1} = 'd = ';
    data{end+1} = ' ';
    data = LocalCreateMatrixData(this.D,data);
else
    data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockNotInLinearizationPath');
end
switch this.Jacobian
    case 'exact'
        str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockLinearizedExact');
    case 'perturbation'
        str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockLinearizedPerturb');
    case 'warning'
        str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockLinearizedWarnings');
    case 'notSupported'
        str = ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockLinearizedNotSupported');
    otherwise
        str = '';
end
data{end+1} = str;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalCreateMatrixData(mat,data)

Space = ' ';
[nrows,ncols] = size(mat);

% Construct matrix display
Columns = cell(1,ncols);
prec = 4;
for ct=1:ncols
    col = cellstr(deblank(num2str(mat(:,ct),prec)));
    Columns{ct} = strjust(strvcat(col{:}),'right');
end

% Equalize column width
lc = cellfun('size',Columns,2);
lcmax = max(lc)+2;
for ct=1:ncols,
    Columns{ct} = [Space(ones(nrows,1), ones(lcmax-lc(ct),1)), Columns{ct}];
end
str = localParseCharArray([Columns{:}],data);

%% LocalFunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalParseCharArray - parses to convert char array with carriage returns
%  to create cell array.
function data = localParseCharArray(strin,data)

% Find the carriage returns
% ind = regexp(strin,'\n');

% Loop over every line
for ct = 1:size(strin,1);
    if ct == 1
        data{end+1} = [sprintf('<A>%s</A>',regexprep(strin(ct,:),' ','&nbsp;')),'<BR>'];
    else
        data{end+1} = [sprintf('<A>%s</A>',regexprep(strin(ct,:),' ','&nbsp;')),'<BR>'];
    end
end
