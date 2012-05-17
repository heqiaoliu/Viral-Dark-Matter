function [sa,data] = createSummaryArea(this) 
% CREATESUMMARYAREA  Create a summary area for the architecture panel.
%
 
% Author(s): John W. Glass 31-Oct-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/12/04 23:26:49 $

% Create the summary area handle
sa = javaObjectEDT('com.mathworks.toolbox.control.explorer.HTMLStatusArea');

% Set the callback
h = handle(sa.getEditor, 'callbackproperties');
h.HyperlinkUpdateCallback = { @LocalEvaluateHyperlinkUpdate, this };

% Define the default font type
fontstr = '<font face="monospaced"; size=3>';

% Get the needed objects
TunedBlocks = this.sisodb.LoopData.C;
ClosedLoopIO = this.ClosedLoopIO;
iotype = get(ClosedLoopIO,{'Type'});

% Label
data = {sprintf(['<table border=0 width="100%%" cellpadding=0 cellspacing=0>',...
             '<tr><td valign=baseline bgcolor="#e7ebf7">',...
             '<b>%sCompensator Design Summary - %s</b></td></tr></table>'],fontstr,this.getModel)};

% Blocks
data{end+1} = sprintf('<B>%sSimulink Blocks to Tune:</B>',fontstr);
for ct = 1:numel(TunedBlocks)
    block = regexprep(TunedBlocks(ct).Name,'\n',' ');
    data{end+1} = sprintf('%s<a href="block:%s">%s</a>', fontstr, block, block);
end
data{end+1} = sprintf('%s ',fontstr);

% Inputs
data{end+1} = sprintf('<B>%sClosed Loop Input Signals:</B>',fontstr);
% Find the closed loop signals with inputs
InputSignals = ClosedLoopIO(find(strcmp(iotype,'in') | ...
                    strcmp(iotype,'inout') | strcmp(iotype,'outin')));
for ct = 1:numel(InputSignals)
    block = InputSignals(ct).Block;
    port = InputSignals(ct).PortNumber;
    data{end+1} = sprintf('%s<a href="signal:%s:%d">%s, output port %d</a>',...
                        fontstr, block, port, block, port);
end
data{end+1} = sprintf('%s ',fontstr);

% Outputs
data{end+1} = sprintf('<B>%sClosed Loop Output Signals:</B>',fontstr);
% Find the closed loop signals with inputs
OutputSignals = ClosedLoopIO(find(strcmp(iotype,'out') | ...
                    strcmp(iotype,'inout') | strcmp(iotype,'outin')));
for ct = 1:numel(OutputSignals)
    block = OutputSignals(ct).Block;
    port = OutputSignals(ct).PortNumber;
    data{end+1} = sprintf('%s<a href="signal:%s:%d">%s, output port %d</a>',...
                        fontstr, block, port, block, port);
end

% Add the new text
sa.setContent(data);

%% LocalFunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalEvaluateHyperlinkUpdate(es,ed,this)

util = slcontrol.Utilities;
evalBlockSignalHyperLink(util,es,ed,this.getModel);
