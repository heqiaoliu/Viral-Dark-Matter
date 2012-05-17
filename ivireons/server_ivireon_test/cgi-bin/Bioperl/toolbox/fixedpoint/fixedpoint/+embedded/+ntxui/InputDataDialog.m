
classdef InputDataDialog < dialogmgr.DialogContent
    % Implement input data dialog for NTX

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:25 $
    
    properties (Access=private)
        % Handles to widgets within the main dialog panel
        hcpStats % toggle panel
        htStatsPrompts
        htStatsInfo
        
        hcpCounts % toggle panel
        htCountPrompts
        htCountInfo
    end
    
    methods
        function dlg = InputDataDialog(ntx)
            dlg.Name = 'Input Data';
            dlg.UserData = ntx; % record NTX application handle
        end
    end
    
    methods (Access=protected)
        function createContent(dlg)
            % Widgets within dialog are created in this method
            %
            % All widgets should be parented to hParent, or to a
            % child of hParent.
            
            hParent = dlg.ContentPanel;
            set(hParent,'tag','inputdata_dialog_panel');
            bg = get(hParent,'BackgroundColor');
            ppos = get(hParent,'pos');
            pdx = ppos(3); % initial width of parent panel, in pixels
            
            inBorder = 2;
            outBorder = 2;
            xL = inBorder; % # pix separation from border to widget
            xb = outBorder; % # pix on each side of panel taken by border line
            
            % Statistics
            
            % Panel to contain content
            content_dy = 14*3;
            stats_x    = 5;
            stats_y    = 1+inBorder;
            stats_dx   = pdx-8;
            stats_dy   = content_dy + 4;
            content_dx = stats_dx - 6;
            
            ppos = [stats_x stats_y stats_dx stats_dy];
            hcp = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ppos, ...
                'Tag','stats_toggle_panel',...
                'Title','Statistics');
            dlg.hcpStats = hcp;
            hPanel = hcp.Panel;
            
            pdx2 = floor(content_dx/2); % midpoint
            dxL  = pdx2-10-xb-xL;     % Make left side 10 pix narrower
            xR   = xL+dxL+3;          % 1-pix gap to start of right side
            dxR  = content_dx-xR-xb-xL;
            
            % Content of stats panel
            str = sprintf('  Max \n  Average \n  Min ');
            dlg.htStatsPrompts = uicontrol( ...
                'parent', hPanel, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'horiz','right', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'fontsize',8, ...
                'pos', [1 2 dxL content_dy], ...
                'style','text', ...
                'tag','stats_prompt',...
                'string',str);
            dlg.htStatsInfo = uicontrol( ...
                'parent', hPanel, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'horiz','left', ...
                'fontsize',8, ...
                'pos', [xR 2 dxR content_dy], ...
                'tag','stats_text',...
                'style','text');

            % Counts
            
            % Panel to contain content
            stats_pos = get(hcp,'Position');
            counts_x  = stats_pos(1);
            counts_y  = stats_pos(2) + stats_pos(4) + 2;
            counts_dx = stats_pos(3);
            counts_dy = 14*4+4;
            ppos = [counts_x counts_y counts_dx counts_dy];
            hcp = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ppos, ...
                'Tag','counts_toggle_panel',...
                'Title','Counts');
            dlg.hcpCounts = hcp;
            hPanel = hcp.Panel;
            
            % Content of counts panel
            content_dy = 14*4;
            str = sprintf('  Total \n  Positive \n  Zero \n  Negative ');
            dlg.htCountPrompts = uicontrol( ...
                'parent', hPanel, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'horiz','right', ...
                'fontsize',8, ...
                'pos', [1 2 dxL content_dy], ...
                'tag','counts_prompt',...
                'style','text', ...
                'string',str);
            dlg.htCountInfo = uicontrol( ...
                'parent', hPanel, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'horiz','left', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'fontsize',8, ...
                'pos', [xR 2 dxR content_dy], ...
                'tag','counts_text',...
                'style','text');
            
            % Final height
            bbox = get(hcp,'Position');
            pdy = bbox(2)+bbox(4);
            set(hParent,'pos',[1 1 pdx pdy]);
        end
        
        function updateContent(dlg)
            % Updates to widgets within dialog are performed in this method
            
            % Max/Avg/Min
            
            ntx = dlg.UserData; % get NTX application object
            dataCount = ntx.DataCount;
            if dataCount>0
                dataAvg = ntx.DataSum / dataCount;
            else
                dataAvg = 0;
            end
            % Print formatted text
            fmt = '%.2g\n%.2g\n%.2g';
            str = sprintf(fmt, ...
                ntx.DataMax,dataAvg,ntx.DataMin);
            set(dlg.htStatsInfo,'string',str);
            
            % Histogram Counts (pos/neg/zero/total)
            
            ntx = dlg.UserData; % get NTX application object
            % Determine largest # digits in ipos, izro, and ineg
            % Use this as the formatting field width for integers
            y = embedded.ntxui.intToCommaSepStr([ ...
                ntx.DataCount,...
                ntx.DataPosCnt, ...
                ntx.DataZeroCnt, ...
                ntx.DataNegCnt]);
            str = embedded.ntxui.leftJustifyCellStrs(y);
            set(dlg.htCountInfo,'string',str);
        end
    end
end
