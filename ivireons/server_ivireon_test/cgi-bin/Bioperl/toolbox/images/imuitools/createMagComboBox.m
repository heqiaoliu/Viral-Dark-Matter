function [cb,cb_api] = createMagComboBox(hToolbar)
%This internal helper function may be removed in a future release.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/07/27 20:15:34 $

%   createMagComboBox is an undocumented function and may be removed in a future
%   version.
    
if isJavaFigure
    import com.mathworks.mwswing.MJPanel;
    import java.awt.BorderLayout;
    
    [cb,cb_api] = immagboxjava;
    
    panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
    panel.add(cb,BorderLayout.WEST)
    javacomponent(panel,0,hToolbar);
end