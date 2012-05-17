function MessagePanel = utCreateNominalModelMessagePanel(this)
%utCreateNominalModelMessagePanel  Create Nominal Model Design message panel

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 16:59:01 $


MessageTextPane = javaObjectEDT('com.mathworks.mwswing.MJTextPane');
MessageTextPane.setName('NominalModelMessage');

MessageTextPane.setContentType('text/html');
MessageTextPane.setEditable(0);
FontName = char(javax.swing.UIManager.getFont('Label.font').getName);
Msg = sprintf('<span style=\"font-size: 11pt\" face=\"%s\">%s</span>', ...
    FontName,ctrlMsgUtils.message('Control:compDesignTask:strNotificationNominalModelDesign'));
MessageTextPane.setText(Msg);
MessageTextPane.setBackground(this.MessagePanel.getBackground)

pathstr = fullfile(matlabroot,'toolbox','shared','controllib','graphics', ...
    'Resources','warning_small.gif');
warnicon = javaObjectEDT('javax.swing.ImageIcon',pathstr);
MessageTextPane.setCaretPosition(1);
MessageTextPane.insertIcon(warnicon);


MessagePanel = MessageTextPane;






 