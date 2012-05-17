classdef ResultingTypeDialog < dialogmgr.DialogContent
    % Implement counts dialog for NTX

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:17:44 $
    
    properties (Access=private)
        % Handles to widgets within the main dialog panel
        hcNumericType         % Checkbox readout
        
        tpDynamicRange        % TogglePanel
        htDynamicRangePrompts % Text prompts
        htDynamicRange        % Text readouts
        
        tpTypeDetails         % TogglePanel
        htTypeDetailsPrompts  % Text prompts
        htTypeDetails         % Text readouts
    end
    
    properties (Constant)
        % Icon caches
        BlankIcon = embedded.ntxui.loadBlankIcon
        WarnIcon  = embedded.ntxui.loadWarnIcon
    end
    
    methods
        function dlg = ResultingTypeDialog(ntx)
            % Setup dialog
            dlg.Name = 'Resulting Type';
            dlg.UserData = ntx; % record NTX application handle
            dlg.CustomContextHandler = true; % use custom context menu
        end
        
        function buildDialogContextMenu(dc,dp)
            % Create context menu items specific to this dialog
            
            ntx = dc.UserData;
            hMainContext = dp.hContextMenu;
            
            % Build context menu for 'Suggest' dialog
            % Add to generic base menu
            % Copy numerictype display string to system clipboard
            % Only create context menu if DTX is turned on
            embedded.ntxui.createContextMenuItem(hMainContext, ...
                'Copy numerictype', ...
                @(h,e)copyNumericTypeToClipboard(ntx));
            
            createBaseContext(dp,dc);
        end
    end
    
    methods (Access=protected)
        function createContent(dlg)
            % Widgets within dialog are created in this method
            %
            % All widgets should be parented to hParent, or to a
            % child of hParent.
            
            hParent = dlg.ContentPanel;
            set(hParent,'tag','resultingtype_dialog_panel');
            bg = get(hParent,'BackgroundColor');
            ppos = get(hParent,'pos');
            pdx = ppos(3); % initial width of parent panel, in pixels
            
            % vertical gutter between bottom of parent panel and the start
            % of dialog content
            yLowerBorder = 4;
            
            outBorder = 2;
            xL = 2;  % # pix separation from border to widget
            xb = outBorder; % # pix on each side of panel taken by border line
            
            % == Type Details (TD) ==
            
            % Define inner position of content panel
            TD_content_dy = 14*6; % content_dy drives inner pos
            TD_x  = 5;
            TD_y  = 1+yLowerBorder;
            TD_dx = pdx-8;
            TD_dy = TD_content_dy + 4;
            TD_content_dx = TD_dx-6; % inner pos dx drives content_dx
            
            ipos = [TD_x TD_y TD_dx TD_dy];
            dlg.tpTypeDetails = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ipos, ...
                'Tag','type_details_toggle_panel',...
                'Title','Type Details');
            
            pdx2 = floor(TD_content_dx/2); % midpoint, shifted 6 pix
            dxL  = pdx2-4-xb-xL+20;     % Make left side 4 pix narrower
            xR   = xL+dxL+3;         % 1-pix gap to start of right side
            dxR  = TD_content_dx-xR-xb-xL;
            
            % Add content to Type Details panel
            hp = dlg.tpTypeDetails.Panel;
            str = sprintf(['Signedness:\n' ...
                'Word length:\nInteger length:\nFraction length:\n' ...
                'Representable Max:\nRepresentable Min:']);
            dlg.htTypeDetailsPrompts = uicontrol( ...
                'parent', hp, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'horiz','right', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'fontsize',8, ...
                'pos',[1 2 dxL TD_content_dy], ...
                'style','text', ...
                'tag','type_details_prompt',...
                'string',str);
            dlg.htTypeDetails = uicontrol( ...
                'parent', hp, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'horiz','left', ...
                'fontsize',8, ...
                'tag','type_details_text',...
                'pos',[xR 2 dxR TD_content_dy], ...
                'style','text');

            
            % == Dynamic Range (DR) ==
            
            % Panel to contain content
            TD_pos = get(dlg.tpTypeDetails,'Position');
            DR_content_dy = 14*3;
            DR_x  = TD_pos(1);
            DR_y  = TD_pos(2) + TD_pos(4) + 2;
            DR_dx = TD_pos(3);
            DR_dy = DR_content_dy + 4;
            
            ipos = [DR_x DR_y DR_dx DR_dy];
            dlg.tpDynamicRange = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ipos, ...
                'Tag','dynamic_range__toggle_panel',...
                'Title','Data Details');
            
            % Add content to Dynamic Range panel
            hp = dlg.tpDynamicRange.Panel;
            str = sprintf('  Outside range \n  Below precision \n  SQNR ');
            dlg.htDynamicRangePrompts = uicontrol( ...
                'parent', hp, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'horiz','right', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'fontsize',8, ...
                'pos',[1 2 dxL DR_content_dy], ...
                'style','text', ...
                'tag','dynamic_range_prompt',...
                'string',str);
            dlg.htDynamicRange = uicontrol( ...
                'parent', hp, ...
                'backgroundcolor', bg, ...
                'units','pix', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'horiz','left', ...
                'fontsize',8, ...
                'tag','dynamic_range_text',...
                'pos',[xR 2 dxR DR_content_dy], ...
                'style','text');
            
            
            % == Numeric Type readout ==
            DR_pos = get(dlg.tpDynamicRange,'Position');

            NT_content_dy = 14*1.5;
            NT_x  = DR_pos(1);
            NT_y  = DR_pos(2) + DR_pos(4);
            NT_dx = DR_pos(3);
            NT_dy = NT_content_dy;
            
            % We specifically do NOT put enable into 'inactive' state
            % The tooltip needs to work on this widget
            % We fore-go the ease-of-use for drag operations
            ipos = [NT_x NT_y NT_dx NT_dy];
            dlg.hcNumericType = uicontrol( ...
                'parent', hParent, ...
                'backgroundcolor',bg, ...
                'tooltip','', ...
                'fontsize',8, ...
                'horiz','left', ...
                'units','pix', ...
                'pos',ipos, ...
                'string','', ...
                'style','checkbox', ...
                'tag','numeric_type_text',...
                'cdata',dlg.BlankIcon);
            
            % Final height
            pdy = NT_y+NT_dy; % overall height of content
            set(hParent,'pos',[1 1 pdx pdy]);
        end
        
        function updateContent(dlg)
            % Updates all widgets within dialog
            
            ntx = dlg.UserData;
            
            % Update Numeric Type checkbox
            %
            s = getNumericTypeStrs(ntx);
            str = s.typeStr;
            if s.isWarn
                icon = dlg.WarnIcon;
                tip  = s.warnTip;
            else
                icon = dlg.BlankIcon;
                tip  = s.typeTip;
            end
            set(dlg.hcNumericType, ...
                'string',str, ...
                'tooltip',tip, ...
                'cdata',icon);
            
            % Update Dynamic Range text
            %
            [ofCnt,ofPct] = getTotalOverflows(ntx);
            [ufCnt,ufPct] = getTotalUnderflows(ntx);
            ycnt = embedded.ntxui.intToCommaSepStr([ofCnt,ufCnt]);
            snr = getSNR(ntx);
            if isnan(snr)
                snrStr = '-'; % reset / unknown
            else
                snrStr = sprintf('%.1f dB', snr);
            end
            str = sprintf([ ...
                '%s (%.1f%%)\n' ...
                '%s (%.1f%%)\n' ...
                '%s'], ...
                ycnt{1},ofPct,ycnt{2},ufPct,snrStr);
            set(dlg.htDynamicRange,'string',str);
            
            % Update Type Details text
            %
            % Include guard- and precision-bits
            qlowerbound = 0;qupperbound = 0;
            [intBits,fracBits,wordBits,isSigned] = getWordSize(ntx,1);
            if ~isempty(wordBits)
                Tx = numerictype('Signed',isSigned,'WordLength',wordBits,...
                    'FractionLength',fracBits,'DataTypeOverride','Off');
                fiObj = fi(0,Tx);
                [qlowerbound  qupperbound] = range(fiObj);
                qlowerbound = double(qlowerbound);
                qupperbound = double(qupperbound);
            end
            if isSigned
                signedStr = 'Signed';
            else
                signedStr = 'Unsigned';
            end
            % Signed, Word, Slope, TypeMax, TypeMin
            str = sprintf('%s\n%d bits\n%d bits\n%d bits\n%-+7.5g\n%-+7.5g', ...
                signedStr, ...
                wordBits,intBits,fracBits, ...
                qupperbound,qlowerbound);
            set(dlg.htTypeDetails,'string',str);
        end
    end
end
