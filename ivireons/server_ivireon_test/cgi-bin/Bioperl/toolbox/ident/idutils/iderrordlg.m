function iderrordlg(errstr,title,parent)
% error dialog for java components
% parent: java frame or dialog handle

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:05:46 $

javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane',...
    parent, errstr, title, com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
