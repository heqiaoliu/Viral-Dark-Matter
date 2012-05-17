function refresh(this, MainDialog, IdentifierIdx)
%REFRESH

%   Author(s): Craig Buhr
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2007/02/06 19:50:37 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;

ImportList = MainDialog.ImportList;

if isequal(IdentifierIdx,-1)
    IdentifierIdx = 0;
end

this.ImportDialog = MainDialog;

% Model Identifiers
for ct = 1:length(ImportList)
    NewList{:,ct} = MainDialog.Design.(ImportList{ct}).Name;
end

% Update ComboBox
ComboBoxModel = awtcreate('javax.swing.DefaultComboBoxModel','[Ljava.lang.Object;',NewList);
awtinvoke(this.Handles.ComboBox,'setModel',ComboBoxModel);
awtinvoke(this.Handles.ComboBox,'setSelectedIndex',IdentifierIdx);
awtinvoke(this.Handles.RadioButton1,'doClick()');
