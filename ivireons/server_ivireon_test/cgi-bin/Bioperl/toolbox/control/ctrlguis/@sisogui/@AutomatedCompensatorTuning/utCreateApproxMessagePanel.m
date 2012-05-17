function MessagePanel = utCreateApproxMessagePanel(this)
%utCreateApproxMessagePanel  Create Time Delay Approximation message panel

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2009/10/16 04:47:34 $


MessageTextPane = javaObjectEDT('com.mathworks.mwswing.MJTextPane');
MessageTextPane.setName('PadeApproxMessage');

MessageTextPane.setContentType('text/html');
MessageTextPane.setEditable(0);
FontName = char(javax.swing.UIManager.getFont('Label.font').getName);
Msg = sprintf('<span style=\"font-size: 11pt\" face=\"%s\">%s</span>', ...
    FontName,ctrlMsgUtils.message('Control:compDesignTask:strNotificationTuningTimeDelay'));
MessageTextPane.setText(Msg);
MessageTextPane.setBackground(this.MessagePanel.getBackground)

h = handle(MessageTextPane, 'callbackproperties');
h.HyperlinkUpdateCallback = {@localPrefCallback, this};


pathstr = fullfile(matlabroot,'toolbox','shared','controllib','graphics', ...
    'Resources','warning_small.gif');
warnicon = javaObjectEDT('javax.swing.ImageIcon',pathstr);
MessageTextPane.setCaretPosition(1);
MessageTextPane.insertIcon(warnicon);


MessagePanel = MessageTextPane;




function localPrefCallback(es,ed,this) %#ok<INUSL>

if strcmp(ed.getEventType.toString, 'ACTIVATED')
    % Determine Hyperlink Description
    Description = char(ed.getDescription);
    switch Description
        case 'Pref'
            % Open Preference Editor to the Options tab.
            this.Preference.edit;
            this.Preference.selecttab('TimeDelays');
    end
end


 