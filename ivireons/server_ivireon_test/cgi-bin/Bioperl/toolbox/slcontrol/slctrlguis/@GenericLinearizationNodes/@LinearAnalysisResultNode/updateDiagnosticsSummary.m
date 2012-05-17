function updateDiagnosticsSummary(this,varargin)
% updateDiagnosticSummary - Update the text field with the diagnostic summary
% Author(s): Zhi Han
    
%   Copyright 2007-2010 The MathWorks, Inc.
% $Revision $   $Date: 2010/04/11 20:41:19 $
    
%% Get the summary area
sa = this.Handles.DiagnosticsSummaryArea;
data = {''};

if strcmp(this.LinearizationOptions.LinearizationAlgorithm, 'blockbyblock')
    DiagnosticMessages = this.DiagnosticMessages;
    if iscell(DiagnosticMessages)
        DiagnosticMessages = DiagnosticMessages{1};
    end
    if isempty(DiagnosticMessages)
        data{end+1} = '<font face="monospaced" size="3">';
        msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsPreviousVersionSCD');
        data{end+1} = sprintf('%s <BR></font>',msg);
    else
        % Filter blocks not in the path if the user chooses
        if ~this.Handles.DiagnosticsPanel.isFullModelSelected
            DiagnosticMessages = DiagnosticMessages([DiagnosticMessages.InPath]);
        end
        
        % Get the diagnostic message types
        types = {DiagnosticMessages.Type};
        messages = {DiagnosticMessages.Message};
        pertblks = strcmp(types,'perturbation');
        exactblks = strcmp(types,'exact') & (~strcmp(messages,''));
        warnblks = xor(strcmp(types,'warning'),exactblks);
        notSupportedblks = strcmp(types,'notSupported');
        msgblks = pertblks | warnblks | notSupportedblks;
        pertblks = pertblks(msgblks);
        warnblks = warnblks(msgblks);
        notSupportedblks = notSupportedblks(msgblks);
        DiagnosticMessages = DiagnosticMessages(msgblks);

        if any(pertblks) || any(warnblks) || any(notSupportedblks)
            % Instruction Message
            data{end+1} = '<font face="monospaced" size="3">';
            data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsTitle','<a href="matlab:scdguihelp(''diagnostic_pane'')">','</a>.<BR><BR>');
            full_names = {DiagnosticMessages.BlockName};

            if ~iscell(full_names)
                assert(ischar(full_names));
                full_names = {full_names};
            end
            if (strcmp(this.LinearizationOptions.UseFullBlockNameLabels, 'on'))
                disp_names = uniqname(slcontrol.Utilities, full_names(:), 0);
            else
                disp_names = uniqname(slcontrol.Utilities, full_names(:), 1);
            end

            if any(notSupportedblks)
                blks = DiagnosticMessages(notSupportedblks);
                blk_disp_name = disp_names(notSupportedblks);
                data{end+1} = '<font face="monospaced" size="3">';
                % Title
                msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsUnsupportedTitle','</a>');
                data{end+1} = sprintf('- <b>%d <a href=HighlightDiagnostic:notSupported>%s</b> <br>',numel(blks),msg);
                data{end+1} = '<BLOCKQUOTE>';
                % Message
                data{end+1} = '<font face="monospaced" size="3">';
                data{end+1} = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsUnsupportedInstruction','<BR></font>');
                % Table
                data = [data,LocalCreateTableHeader(sprintf('Message'))];
                for ct = 1:numel(blks)
                    data = [data,LocalCreateTableRow(blks(ct).BlockName,blk_disp_name{ct},blks(ct).Message)];
                end
                data{end+1} = '</table><br>';
                data{end+1} = '</blockquote>';
            end

            if any(warnblks)
                blks = DiagnosticMessages(warnblks);
                blk_disp_name = disp_names(warnblks);

                % Create the table data first since we do not know how many
                % messages there will be.
                ctr = 0;
                rowdata = {};
                for ct = 1:numel(blks)
                    if ~isempty(blks(ct).Message)
                        rowdata = [rowdata,LocalCreateTableRow(blks(ct).BlockName,blk_disp_name{ct},blks(ct).Message)];
                        ctr = ctr + 1;
                    end
                end
                if ctr > 0
                    data{end+1} = '<font face="monospaced" size="3">';
                    % Title
                    msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsWarningTitle','</a>');
                    data{end+1} = sprintf('- <b>%d <a href=HighlightDiagnostic:warning>%s</b><br>',ctr,msg);
                    data{end+1} = '<blockquote>';
                    % Message
                    data{end+1} = '<font face="monospaced" size="3">';
                    msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsWarningInstruction');
                    data{end+1} = sprintf('%s</font><br>',msg);
                    % Table
                    data = [data,LocalCreateTableHeader(sprintf('Message'))];
                    data = [data,rowdata];
                    data{end+1} = '</table><BR>';
                    data{end+1} = '</blockquote>';
                end
            end

            if any(pertblks)
                blks = DiagnosticMessages(pertblks);
                data{end+1} = '<font face="monospaced" size="3">';
                % Title
                msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsPerturbationTitle','</a>');
                data{end+1} = sprintf('- <b>%d <a href=HighlightDiagnostic:perturbation>%s</b> <br>',numel(blks),msg);
                data{end+1} = '<font face="monospaced" size="3">';
                data{end+1} = '<blockquote>';
                % Message
                data{end+1} = '<font face="monospaced" size="3">';
                msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsPerturbationInstruction');
                data{end+1} = sprintf('%s</font><br>',msg);    
                data{end+1} = '</blockquote>';
            end

        else
            data{end+1} = '<font face="monospaced" size="3">';
            msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:DiagnosticsAllBlocksLinearizedExactly');
            data{end+1} = sprintf('- %s<br></font>',msg);
        end
    end
else
    return
end

% Add the new text
sa.setContent([data{:}]);

%% 
function data = LocalCreateTableHeader(MessageType)
data = cell(1,4);
data{1} = '<table cellspacing="1" cellpadding="0" border="1">';
data{2} = '<tr><th bgcolor="#B2B2B2">';
data{3} = sprintf('<font face="monospaced"> <b> Block</b></font></th>');
data{4} = sprintf('<th bgcolor="#B2B2B2"><font face="monospaced"; size="3"><b>%s</b></font></th></tr>',MessageType);

%%
function data = LocalCreateTableRow(BlockName,BlockDisplayName,Message)
data = cell(1,3);
data{1} = '<tr><td valign="top" bgcolor="#F2F2F2">';
data{2} = sprintf('<font face="monospaced" size="3"><a href="block:%s">%s</a></font></td>', BlockName, BlockDisplayName);
data{3} = sprintf('<td  bgcolor="#F2F2F2"><font face="monospaced"; size=3>%s</font></td></tr>', Message);
