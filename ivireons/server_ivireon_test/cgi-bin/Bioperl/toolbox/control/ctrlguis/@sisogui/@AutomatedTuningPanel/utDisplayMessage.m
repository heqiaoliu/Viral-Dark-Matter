function utDisplayMessage(this,type,msg)
%

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/07/09 20:51:13 $

if ~isempty(msg)
    jObj = javaObjectEDT('com.mathworks.mwswing.MJOptionPane');
    switch type
        case 'warning'
            javaMethodEDT('showMessageDialog',jObj,slctrlexplorer, ...
                 xlate(msg), xlate(this.MessageDialogTitle), com.mathworks.mwswing.MJOptionPane.WARNING_MESSAGE);
        case 'error'
            javaMethodEDT('showMessageDialog',jObj,slctrlexplorer, ...
                 xlate(msg), xlate(this.MessageDialogTitle), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
    end
end
