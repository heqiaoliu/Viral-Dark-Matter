function Card = utBuildSpecialSpec(this, MethodName, CardName, TextInfo)
% utility function

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/04/11 20:29:55 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;


GBc = GridBagConstraints;
GBc.insets=Insets(10,10,10,10);
GBc.anchor = GridBagConstraints.CENTER;
GBc.fill = GridBagConstraints.HORIZONTAL;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.weighty   = 0;
GBc.weightx   = 1;

Card = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
Card.setName(strcat(MethodName,'_',CardName));
title = BorderFactory.createTitledBorder(xlate(' Specifications '));
Card.setBorder(title);
if nargin<=3
    Label = javaObjectEDT('com.mathworks.mwswing.MJLabel',blanks(10));
else
    Label = javaObjectEDT('com.mathworks.mwswing.MJTextPane');
    Label.setName('SpecialSpecTextPane');
    Label.setText(TextInfo);
    Label.setEditable(false);
    Label.setBackground(Card.getBackground);
    Label.setForeground(Card.getForeground);
end
Card.add(Label, GBc);
