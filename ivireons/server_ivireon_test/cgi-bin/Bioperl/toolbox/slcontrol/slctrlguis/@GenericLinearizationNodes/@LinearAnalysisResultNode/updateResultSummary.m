function updateResultSummary(this,varargin)
% updateResultSummary - Update the text field with the result summary
%  Author(s): John Glass
%  Copyright 2004-2008 The MathWorks, Inc.
%	$Revision: 1.1.6.19 $  $Date: 2009/06/11 16:09:15 $

if nargin == 2
    DialogPanel = varargin{1};
else
    DialogPanel = this.Dialog;
end

% Get the summary area handle and lti system
sa = this.Handles.SummaryArea;

% Get the index to the selected linearization
if size(this.LinearizedModel,3) > 1
    combo_index = DialogPanel.getSelectedModelIndex;
else
    combo_index = 1;
end
sys = this.LinearizedModel(:,:,combo_index);

% Label
data = {'<font face="monospaced"; size=3>'};
data{end+1} = sprintf('<B>Linearization Result:</B><BR>');
data{end+1} = '<BR>';
data{end+1} = sprintf('&nbsp;-&nbsp;To plot the response of this result click on the node labeled Custom Views.<BR>');

% Get the selected element
mode = DialogPanel.getLinearAnalysisSummaryPanel.getLTITypeCombo.getSelectedIndex;

nstates = length(sys.a);
data{end+1} = sprintf('&nbsp;-&nbsp;To export the result click on the Export To Workspace button below.<BR>');

oldInputName = sys.InputName;
ninputs = numel(sys.InputName);
inputlabels = oldInputName;
for ct = 1:ninputs
    inputlabels{ct} = sprintf('u%d',ct);
end
oldOutputName = sys.OutputName;
noutputs = numel(sys.OutputName);
outputlabels = oldOutputName;
for ct = 1:noutputs
    outputlabels{ct} = sprintf('y%d',ct);
end
sys.InputName = inputlabels;
sys.OutputName = outputlabels;

if mode == 0
    if nstates <= 100
        statelabels = cell(nstates,1);
        for ct = 1:nstates
            statelabels{ct} = sprintf('x%d',ct);
        end
        % Replace state names with the indices x1, x2,... that are summarized
        % below.
        StateName = sys.StateName;
        sys.StateName = statelabels;

        % Find the full state names in the model
        if isempty(this.IOStructure) || (combo_index > numel(this.IOStructure))
            stateBlockPath = StateName;
        else
            stateBlockPath = this.IOStructure(combo_index).FullStateName;
        end

        % State space mode
        data = localParseCharArray(evalc('display(sys)'),data);
        data{end+1} = '<BR>';
        data{end+1} = sprintf('<B>State Names:</B><BR>');
        for ct = 1:nstates
            state_name = slname2html(slcontrol.Utilities,StateName{ct});
            if ~strcmp(stateBlockPath{ct},'?')
                block = slname2html(slcontrol.Utilities,stateBlockPath{ct});
                data{end+1} = sprintf('x%d - <a href="block:%s">%s</a><BR>',ct,block,state_name);
            elseif strcmp(stateBlockPath{ct},'?') && ...
                    strcmp(this.LinearizationOptions.RateConversionMethod,'zoh')
                data{end+1} = sprintf('x%d - State added during rate conversion.<BR>',ct);
            else
                data{end+1} = sprintf('x%d - State name lost in rate conversion.<BR>',ct);
            end
        end
    else  
        msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:TooManyStatesToDisplayInSummary');
        data{end+1} = sprintf('&nbsp;-&nbsp;%s<BR>',msg);
    end
elseif mode == 1
    % Zero pole gain mode
    if isempty(sys.InternalDelay)
        data = localParseCharArray(evalc('display(zpk(sys))'),data);
    else
        data{end+1} = '<BR>Models with internal delays cannot be viewed in the Zero Pole Gain format.  Please use the State Space format.<BR>';
    end
else
    % Transfer function mode
    if isempty(sys.InternalDelay)
        data = localParseCharArray(evalc('display(tf(sys))'),data);
    else
        data{end+1} = '<BR>Models with internal delays cannot be viewed in the Transfer Function format.  Please use the State Space format.<BR>';
    end
end


data{end+1} = '<BR>';
data{end+1} = sprintf('<A><B>Input Channel Names:</B><BR></A>');
if ~isempty(this.IOStructure)
    for ct = 1:ninputs
        block = slname2html(slcontrol.Utilities,oldInputName{ct});
        data{end+1} = sprintf('u%d - <a href="signal:%s:%d">%s</a><BR>',...
            ct,...
            this.IOStructure(1).FullInputName{ct},...
            this.IOStructure(1).FullInputPort(ct),...
            block);
    end
else
    for ct = 1:ninputs
        block = slname2html(slcontrol.Utilities,oldInputName{ct});
        data{end+1} = sprintf('u%d - %s',ct,block);
    end
end

data{end+1} = '<BR>';
data{end+1} = sprintf('<B>Output Channel Names:</B><BR>');
if ~isempty(this.IOStructure)
    for ct = 1:noutputs
        block = slname2html(slcontrol.Utilities,oldOutputName{ct});
        data{end+1} = sprintf('y%d - <a href="signal:%s:%d">%s</a><BR>',...
            ct,...
            this.IOStructure(1).FullOutputName{ct},...
            this.IOStructure(1).FullOutputPort(ct),...
            block);
    end
else
    for ct = 1:noutputs
        block = slname2html(slcontrol.Utilities,oldOutputName{ct});
        data{end+1} = sprintf('y%d - %s',ct,block);
    end
end

% Add the new text
sa.setContent([data{:}]);

%% LocalFunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalParseCharArray - parses to convert char array with carriage returns
%  to create cell array.
function data = localParseCharArray(strin,data)

% Find the carriage returns
ind = regexp(strin,'\n');

% Loop over every line
for ct = 1:length(ind);
    if ct == 1
        data{end+1} = [sprintf('<A>%s</A>',regexprep(strin(1:ind(ct)),' ','&nbsp;')),'<BR>'];
    else
        data{end+1} = [sprintf('<A>%s</A>',regexprep(strin(ind(ct-1):ind(ct)),' ','&nbsp;')),'<BR>'];
    end
end