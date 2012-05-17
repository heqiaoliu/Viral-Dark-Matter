function Btnpanel = buttonpanel(this)
% BUTTONPANEL Create the standard button panel for the import dialog.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:37:08 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.page.utils.VertFlowLayout;
import javax.swing.table.*;
import javax.swing.border.*;

FlowLayout = javaObjectEDT('java.awt.FlowLayout',java.awt.FlowLayout.RIGHT);
Btnpanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout);
 
Btn1 = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Import'));
Btn1.setName('Import')
h = handle( Btn1, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImport this};

Btn2 = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Close'));
Btn2.setName('Close');
h = handle( Btn2, 'callbackproperties');
h.ActionPerformedCallback = {@LocalClose this};

Btn3 = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Help'));
Btn3.setName('Help')
h = handle( Btn3, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHelp, this};

Btnpanel.add(Btn1);
Btnpanel.add(Btn2);
Btnpanel.add(Btn3);

this.Handles.ImportButton = Btn1;
this.Handles.CloseButton = Btn2;
this.Handles.HelpButton = Btn3;

% ------------------------------------------------------------------------%
% Function: LocalClose
% Purpose:  Destroy dialog Frame
% ------------------------------------------------------------------------%
function LocalClose(~, ~, this)

Frame = this.Frame;
delete(this);
awtinvoke(Frame,'dispose');
%Frame.dispose;

% ------------------------------------------------------------------------%
% Function: LocalImport
% Purpose:  Import selected model
% ------------------------------------------------------------------------%
function LocalImport(~, ~, this)

this.import

% ------------------------------------------------------------------------%
% Function: LocalHelp
% Purpose:  Open Help
% ------------------------------------------------------------------------%
function LocalHelp(~, ~, this)

this.help
