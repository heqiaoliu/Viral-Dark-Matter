function showMessagePanel(this,Flag,Panel)
%showMessagePanel  Shows message panel

%   Author(s): C. Buhr
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/08/08 01:09:09 $


if Flag
    import java.awt.*;
    import javax.swing.* ;
    import javax.swing.border.*;
    import java.util.* ;
    this.MessagePanel.removeAll;
    gbc           = GridBagConstraints;
    gbc.anchor    = GridBagConstraints.NORTHWEST;
    gbc.fill      = GridBagConstraints.BOTH;
    gbc.gridheight= 1;
    gbc.gridwidth = 1;
    gbc.gridx = 0;
    gbc.gridy = 0;
    gbc.insets    = Insets(0,5,5,5);
    gbc.weightx   = 1;
    gbc.weighty   = 1;
    this.MessagePanel.add(Panel,gbc);
    setVisible(this.MessagePanel,Flag);
    Panel.revalidate;
    Panel.repaint;

else
    this.MessagePanel.removeAll;
    this.MessagePanel.invalidate;
    this.MessagePanel.repaint;
end
