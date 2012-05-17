classdef StartupDlg < handle
    % @StartupDlg defines welcome message dialog

    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.5 $ $Date: 2010/03/26 17:21:31 $

    properties
        % handles of java components
        Figure
        TextMsg
        HelpBtn
    end

    methods    
        function this = StartupDlg(FigHndl)
            %STARTUPDLG  Opens and manages the start-up dialog.
            % FigHndl is the handle of the main figure window
            % Preferences is the handle to the Toolbox Preferences
            % Handles is a structure containing handles of objects 

            % Parameters
            StdColor = get(0,'DefaultUIControlBackground');
            StdUnit = 'character';
            StdFontSize = 10;
            FigW = 85;
            FigH = 9;
            hBorder = 1.5;
            vBorder = 0.5;
            BW = (FigW-5*hBorder)/4;
            BH = 1.5;

            % Create figure
            STARTMSGFig = figure('Color',StdColor, ...
                'IntegerHandle','off', ...
                'Units',StdUnit,...
                'Resize','off',...
                'MenuBar','none', ...
                'NumberTitle','off', ...
                'HandleVisibility','callback',...
                'Visible','off',...
                'Name', pidtool.utPIDgetStrings('cst','startupdlg_title'), ...
                'Position',[10 10 FigW FigH],...
                'DockControls', 'off');

            this.Figure = STARTMSGFig;
            centerfig(STARTMSGFig,FigHndl);

            % Create the don't show again checkbox
            X0 = hBorder;
            Y0 = vBorder;
            nBW = BW*1.8;
            chkboxHndl = uicontrol('Parent',STARTMSGFig, ...
                'Style','checkbox', ...
                'Units',StdUnit, ...
                'FontSize', StdFontSize, ...
                'Position',[X0 Y0 nBW BH], ...
                'String',pidtool.utPIDgetStrings('cst','startupdlg_checkbox'), ...
                'HorizontalAlignment', 'left');

            % Button group
            X0 = FigW - 2*hBorder-2*BW;
            Y0 = vBorder;
            X0 = X0+hBorder+BW;
            uicontrol('Parent',STARTMSGFig, ...
                'Units',StdUnit, ...
                'FontSize', StdFontSize, ...
                'Position',[X0 Y0 BW BH], ...
                'String',pidtool.utPIDgetStrings('cst','button_close'), ...
                'Callback', {@LocalCloseBtnCB chkboxHndl} );
            
            % Create the text message
            X0 = hBorder;
            Y0 = 5*vBorder;
            BW = FigW - 2*hBorder;
            BH = 12*vBorder;
            Handles.TextMsg = uicontrol('Parent',STARTMSGFig, ...
                'Style','text', ...
                'Units',StdUnit, ...
                'FontSize', StdFontSize, ...
                'Position',[X0 Y0 BW BH], ...
                'String',sprintf('%s\n\n%s',...
                    pidtool.utPIDgetStrings('cst','startupdlg_msg1'),...
                    pidtool.utPIDgetStrings('cst','startupdlg_msg2')),...
                'HorizontalAlignment', 'left');

            % Create and store, a listener to delete the message box when the sisotool is closed
            listener = addlistener(FigHndl, 'ObjectBeingDestroyed', ...
                @(es,ed) localDeleteMsgBox(STARTMSGFig));
            set(STARTMSGFig, 'UserData', listener);

            % Make the figure visible
            set(STARTMSGFig,'Visible','on');

        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCloseBtnCB %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalCloseBtnCB(eventSrc, eventData, chkboxHndl) %#ok<*INUSL>
    h = cstprefs.tbxprefs;
    s = h.PIDTunerPreferences;
    if get(chkboxHndl,'Value')
        s.DefaultWelcomeDialog = 'off';
    end
    % backward compatibility
    if ~isnumeric(s.TunedColor)
        s.TunedColor = [s.TunedColor.getRed/256 s.TunedColor.getGreen/256 s.TunedColor.getBlue/256];
    end
    if ~isnumeric(s.BlockColor)
        s.BlockColor = [s.BlockColor.getRed/256 s.BlockColor.getGreen/256 s.BlockColor.getBlue/256];
    end
    h.PIDTunerPreferences = s;
    h.save
    delete(get(chkboxHndl,'Parent'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDeleteMsgBox %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeleteMsgBox(STARTMSGFig)
    % Deletes the start-up message box when the main window is deleted
    if ishghandle(STARTMSGFig)
        delete(STARTMSGFig);
    end
end
