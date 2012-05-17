function updateSummary(this)
% UPDATESUMMARY  Update the text field with the compensator summary
%
 
% Author(s): John W. Glass 16-Aug-2005
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/04/11 20:29:47 $

%% Get the summary area handle and lti system
sa = this.Handles.SummaryArea;

%% Define the default font type
[textstr,codestr] = LocalDefaultFontTyes;

%% Label
data = {sprintf(['<table border=0 width="100%%" cellpadding=0 cellspacing=0>',...
             '<tr><td valign=baseline bgcolor="#e7ebf7">',...
             '<b>Design Snapshot Summary - %s</b></td></tr></table>'],this.Label)};

data = {sprintf('<B><FONT FACE=sans-serif SIZE=4 COLOR=#800000>Design Snapshot Summary - %s</FONT></B>',this.Label)};
data{end+1} = '';

%% Get the design object
task = getSISOTaskNode(this);
sisodb = task.sisodb;
ind = find(strcmp(get(sisodb.LoopData.History,{'Name'}),this.Label));
Design = sisodb.LoopData.History(ind);

%% Report the design configuration
config = sisodb.LoopData.getconfig;
data{end+1} = sprintf('<b>%sDesign Configuration #%d</b>',textstr,config);
data{end+1} = ' ';
imageicon = sisogui.getIconPath(config);
data{end+1} = sprintf('<html><img src="file:\\%s"></img>',imageicon);
data{end+1} = ' ';

%% Loop over each of the tuned blocks
Tuned = Design.Tuned;
for ct = numel(Tuned):-1:1
    TunedBlocks(ct) = Design.(Tuned{ct});
end

data{end+1} = sprintf('<b>%sTunable Elements</b>',textstr);
data = LocalWriteBlocks(data,TunedBlocks);

%% Loop over each of the fixed elements
Fixed = Design.Fixed;
for ct = numel(Fixed):-1:1
    FixedBlocks(ct) = Design.(Fixed{ct});
end

data{end+1} = sprintf('<b>%sFixed Elements</b>',textstr);         
data = LocalWriteBlocks(data,FixedBlocks);




%% Clear the text
sa.clearText;
%% Add the new text
sa.setContent(data);
drawnow
%% Set the cursor to be at zero
sa.setCursoratZero;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = LocalWriteBlocks(data,TunedBlocks)
[textstr,codestr] = LocalDefaultFontTyes;
for ct = 1:numel(TunedBlocks)
    data{end+1} = sprintf('%s%s:',codestr,TunedBlocks(ct).Name);
    Model = TunedBlocks(ct).Value;
    ModelSize = size(Model);
    if prod(ModelSize(3:end)) > 1
        data = GetArrayTable(data,Model);
    elseif isa(Model,'frd')
        data = GetFRDTable(data,Model);
    elseif hasdelay(Model)
        data = GetModelWithDelayTable(data,Model);
    else
        % Can be represented as zpk
        data = GetZPKTable(data,Model);
    end
    
    
end
end

function [textstr,codestr] = LocalDefaultFontTyes
%% Define the default font type
codestr = '<font face="monospaced"; size=3>';
textstr = '<font face=sans-serif SIZE=3>';
end


function data = GetZPKTable(data,Model)
[textstr,codestr] = LocalDefaultFontTyes;
            data{end+1} = sprintf(['<table cellspacing="0" cellpadding="4" class="body" ',...
                'summary="Parameter Values" border="1">',...
                '<colgroup><col width="40%"><col width="40%"></colgroup>']);
            % specify the rows
            data{end+1} = sprintf(['<tr valign="top"><th bgcolor="#B2B2B2" valign="top">',...
                '%sParameter</th></font><th bgcolor="#B2B2B2" valign="top">%sValue</font></th></tr>'],textstr,textstr);
            %% Get the zpkdata
[z,p,k] = zpkdata(Model,'v');
            %% Gain
            strvalue = mat2str(k);
            data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
                       '<td bgcolor="#F2F2F2" align="center"><tt>%s%s</tt></td></tr>'],...
                textstr,...
                xlate('Gain'),...
                codestr,...
                strvalue);
            %% Zeros
            if isempty(z)
                strvalue = '[]';
            else
                strvalue = mat2str(z);
            end
            data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
                       '<td bgcolor="#F2F2F2" align="center"><tt>%s%s</tt></td></tr>'],...
                textstr,...
                xlate('Zeros'),...
                codestr,...
                strvalue);
            %% Poles
            if isempty(p)
                strvalue = '[]';
            else
                strvalue = mat2str(p);
            end
            data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
                       '<td bgcolor="#F2F2F2" align="center"><tt>%s%s</tt></td></tr>'],...
                textstr,...
                xlate('Poles'),...
                codestr,...
                strvalue);
            data{end+1} = '</TABLE>';
        end

function data = GetFRDTable(data,Model)
[textstr,codestr] = LocalDefaultFontTyes;
data{end+1} = sprintf(['<table cellspacing="0" cellpadding="4" class="body" ',...
    'summary="Model Type" border="1">',...
    '<colgroup><col width="40%"><col width="40%"></colgroup>']);
% specify the rows
data{end+1} = sprintf(['<tr valign="top"><th bgcolor="#B2B2B2" valign="top">',...
    '%sModel Type</th></font></tr>'],textstr);
data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
    '</tr>'],...
    codestr,...
    xlate('Frequency Response Data Model'));
data{end+1} = '</TABLE>';
    end

function data = GetModelWithDelayTable(data,Model)
[textstr,codestr] = LocalDefaultFontTyes;
data{end+1} = sprintf(['<table cellspacing="0" cellpadding="4" class="body" ',...
    'summary="Model Type" border="1">',...
    '<colgroup><col width="40%"><col width="40%"></colgroup>']);
% specify the rows
data{end+1} = sprintf(['<tr valign="top"><th bgcolor="#B2B2B2" valign="top">',...
    '%sModel Type</th></font></tr>'],textstr);
data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
    '</tr>'],...
    codestr,...
    xlate('Model with Time Delays'));
data{end+1} = '</TABLE>';
end


function data = GetArrayTable(data,Model)
[textstr,codestr] = LocalDefaultFontTyes;
data{end+1} = sprintf(['<table cellspacing="0" cellpadding="4" class="body" ',...
    'summary="Model Type" border="1">',...
    '<colgroup><col width="40%"><col width="40%"></colgroup>']);
% specify the rows
data{end+1} = sprintf(['<tr valign="top"><th bgcolor="#B2B2B2" valign="top">',...
    '%sModel Type</th></font></tr>'],textstr);
sz = size(Model);
data{end+1} = sprintf(['<tr valign="top"><td bgcolor="#F2F2F2">%s%s</FONT></td>',...
    '</tr>'],...
    codestr,...
    ctrlMsgUtils.message('Control:compDesignTask:strModelArrayLabel',sz(3),sz(4)));
data{end+1} = '</TABLE>';
    end