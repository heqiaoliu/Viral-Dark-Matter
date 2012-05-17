function updateSummary(this)
% UPDATESUMMARY  Update the text field with the compensator summary
%
 
% Author(s): John W. Glass 16-Aug-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/10/15 23:32:01 $

% Get the summary area handle and lti system
sa = this.Handles.SummaryArea;

% Get the task node
task = getSISOTaskNode(this);

% Set the callback
h = handle(sa.getEditor, 'callbackproperties');
h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate, task};

% Define the default font type
codestr = '<font face="monospaced"; size=3>';
textstr = '<font face=sans-serif SIZE=3>';

% Label
data = {sprintf('<B><FONT FACE=sans-serif SIZE=4 COLOR=#800000>Design Snapshot Summary - %s</FONT></B>',this.Label)};
data{end+1} = '';

% Evaluate the precision if needed
OptionsStruct = task.TaskOptions;
if ~OptionsStruct.UseFullPrecision
    try
        prec = evalScalarParam(linutil,OptionsStruct.CustomPrecision);
    catch
        msg = ctrlMsgUtils.message('Slcontrol:controldesign:InvalidCustomPrecisionExpression',OptionsStruct.CustomPrecision);
        errordlg(msg,xlate('Simulink Control Design'))
        return
    end
else
    prec = NaN;
end

% Get the design object
sisodb = task.sisodb;
Design = sisodb.LoopData.History(strcmp(get(sisodb.LoopData.History,{'Name'}),this.Label));

% Loop over each of the tuned blocks
Tuned = Design.Tuned;
for ct = numel(Tuned):-1:1
    TunedBlocks(ct) = Design.(Tuned{ct});
end

for ct = 1:numel(TunedBlocks)
    data{end+1} = sprintf('%sTuned Block - <a href="block:%s">%s%s</a>:',...
                        textstr,TunedBlocks(ct).Name,codestr,TunedBlocks(ct).Name);
    data{end+1} = sprintf(['<table cellspacing="0" cellpadding="4" class="body" ',...
                   'summary="Tunable Block Parameter Values" border="1">',...
                   '<colgroup><col width="40%"><col width="40%"></colgroup>']);
    % specify the rows    
    data{end+1} = sprintf(['<tr valign="top"><th bgcolor="#B2B2B2" valign="top">',...
                   '%sParameter</th></font><th bgcolor="#B2B2B2" valign="top">%sValue</font></th></tr>'],textstr,textstr);
    Parameters = TunedBlocks(ct).getProperty('Parameters');
    for ct2 = 1:numel(Parameters)
        %% Compute the parameter string
        strvalue = computeParameterString(linutil,Parameters(ct2).Value,prec);
        data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
                       '<td bgcolor="#F2F2F2" align="center"><tt>%s%s</tt></td></tr>'],...
                       textstr,...
                       Parameters(ct2).Name,...
                       codestr,...
                       strvalue);
    end
    data{end+1} = '</TABLE>';    
end

% Clear the text
sa.clearText;
% Add the new text
sa.setContent(data);
drawnow
% Set the cursor to be at zero
sa.setCursoratZero;

%% LocalFunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalEvaluateHyperlinkUpdate(es,ed,task)

util = slcontrol.Utilities;
evalBlockSignalHyperLink(util,es,ed,task.getModel);