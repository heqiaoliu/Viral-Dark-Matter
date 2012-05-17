classdef InitialConditionDlg < handle
    % @ImportPlantDlg imports new LTI plant at specified operating point

    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/04/21 22:04:58 $
    
    properties
        Handles
        AbortLinearization  % false if "continue" is clicked
    end

    methods

        % Constructor
        function this = InitialConditionDlg(Parent,BackgroundColor,Mode)
            % Parent: parent window that determines the location
            % BackgroundColor: background color
            % Mode: 'launch' or 'import'
            this.AbortLinearization = true;
            this.build(BackgroundColor,Mode);
            this.show(Parent, Mode);
        end
        
    end
    
    methods (Access = protected)

        function build(this, BackgroundColor ,Mode)
            
            %% create figure
            fig = figure('Color',BackgroundColor,...
                 'IntegerHandle','off', ...
                 'Menubar','None',...
                 'Toolbar','None',...
                 'DockControl','off',...
                 'Name',pidtool.utPIDgetStrings('scd','initialdlg_title'), ...
                 'units','character',...
                 'NumberTitle','off', ...
                 'Visible','off', ...
                 'Tag','ImportPlantDlg',...
                 'WindowStyle','modal',...
                 'HandleVisibility','off');
            
            %% create description panel
            DescPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            Info = javaObjectEDT('com.mathworks.toolbox.control.explorer.HTMLStatusArea');
            data = {'<font face="monospaced" size="3">'};
            str_hyper = ['<a href="matlab:scdguihelp(''pidtuner_dochelp'')">' ctrlMsgUtils.message('Slcontrol:pidtuner:initialdlg_description1') '</a>'];
            str_main1 = ctrlMsgUtils.message('Slcontrol:pidtuner:initialdlg_description2');
            str_main2 = ctrlMsgUtils.message('Slcontrol:pidtuner:initialdlg_description3');
            str_main3 = ctrlMsgUtils.message('Slcontrol:pidtuner:initialdlg_description4');
            str_main4 = ctrlMsgUtils.message('Slcontrol:pidtuner:initialdlg_description5');
            str_main5 = ctrlMsgUtils.message('Slcontrol:pidtuner:initialdlg_description6',str_hyper);
            data{2} = [str_main1 '<BR><BR>' str_main2 '<BR><BR>' str_main3 '<BR><BR>' str_main4 '<BR><BR>' str_main5];
            Info.setContent([data{:}]);
            DescPanel.setLayout(javaObjectEDT('java.awt.BorderLayout',10,10));
            DescPanel.add(Info,java.awt.BorderLayout.CENTER);
            
            %% main panel
            Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            Panel.setLayout(java.awt.BorderLayout(5,8));
            Panel.add(DescPanel,java.awt.BorderLayout.CENTER);
            [~, PanelCONTAINER] = javacomponent(Panel,[.1,.1,.9,.9],fig);
            set(PanelCONTAINER,'units','character')
            
            %% create button panel
            % launch
            LaunchButtonCardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            LaunchButtonCardPanel.setName('LaunchPanel')
            LaunchButtonCardPanel.setLayout(java.awt.FlowLayout);
            % continue
            ContinueButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('scd','initialdlg_btn1'));
            ContinueButton.setName('INITIALDLG_CONITNUEBUTTON');
            % cancel
            CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('scd','initialdlg_btn2'));
            CancelButton.setName('INITIALDLG_CANCELBUTTON');
            % add buttons
            LaunchButtonCardPanel.add(ContinueButton);
            LaunchButtonCardPanel.add(CancelButton);
            % import
            ImportButtonCardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            ImportButtonCardPanel.setName('ImportPanel')
            ImportButtonCardPanel.setLayout(java.awt.FlowLayout);
            % ok
            OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('scd','initialdlg_btn3'));
            OKButton.setName('INITIALDLG_OKBUTTON');
            % add buttons
            ImportButtonCardPanel.add(OKButton);
            % add card
            CardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',java.awt.CardLayout);
            CardPanel.setName('CardPanel')
            CardPanel.add(LaunchButtonCardPanel,'launch');
            CardPanel.add(ImportButtonCardPanel,'import');
            CardPanel.getLayout.show(CardPanel,Mode);
            % add to uipanel
            ButtonPanel = uipanel('parent',fig,'bordertype','none','units','character','BackgroundColor', BackgroundColor);
            [~, CardPanelCONTAINER] = javacomponent(CardPanel,[.1,.1,.9,.9],ButtonPanel);
            set(CardPanelCONTAINER,'units','character');
            
            this.Handles.Figure = fig;
            this.Handles.ButtonPanel = ButtonPanel;
            this.Handles.PanelCONTAINER = PanelCONTAINER;
            this.Handles.CardPanelCONTAINER = CardPanelCONTAINER;
            this.Handles.Info = Info;

            % callbacks
            h = handle(ContinueButton,'callbackproperties');
            h.ActionPerformedCallback = {@ContinueButtonCallback this};
            h = handle(CancelButton,'callbackproperties');
            h.ActionPerformedCallback = {@CancelButtonCallback this};
            h = handle(OKButton,'callbackproperties');
            h.ActionPerformedCallback = {@OKButtonCallback this};
            h = handle(Info.getEditor, 'callbackproperties');
            h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate};
            
            %% figure callbacks
            set(fig,...
                'ResizeFcn',@(x,y) layout(this),...
                'CloseRequestFcn',@(x,y) close(this));

        end
        
        % resize function
        function layout(this)
            p = get(this.Handles.Figure,'Position');
            fw = p(3);  fh = p(4);
            set(this.Handles.ButtonPanel,'Position',[0, 0, fw, 3]);
            set(this.Handles.CardPanelCONTAINER,'Position',[0, 0, fw, 3]);
            set(this.Handles.PanelCONTAINER,'Position',[2, 4, max(0.01,fw-4), max(0.01,fh-5)]);
        end

        % set visibility
        function show(this, Parent, Mode)
            set(this.Handles.Figure,'Position',[0 0 100 25]);
            if strcmp(Mode,'launch')
                dlgsz = get(Parent,'position');
                tmp = figure('position',dlgsz,'visible','off');
                centerfig(this.Handles.Figure,tmp);
                delete(tmp);
            else
                centerfig(this.Handles.Figure,Parent);
            end
            set(this.Handles.Figure,'Visible','on');
        end
        
        % close function
        function close(this)
            delete(this.Handles.Figure);
        end

    end
    
end

%% Callbacks
function OKButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
    close(this);
end

function CancelButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
    close(this);
end

function ContinueButtonCallback(hObject,eventdata,this)
    this.AbortLinearization = false;
    close(this);
end

%% LocalEvaluateHyperlinkUpdate
function LocalEvaluateHyperlinkUpdate(hSrc, hData)
    % Evaluate the hyperlink
    if strcmp(hData.getEventType.toString, 'ACTIVATED')
        Description = char(hData.getDescription);
        typeind = findstr(Description,':');
        identifier = Description(1:typeind(1)-1);
        if strcmp(identifier,'matlab')
            eval(Description(typeind+1:end))
        end
    end
end


