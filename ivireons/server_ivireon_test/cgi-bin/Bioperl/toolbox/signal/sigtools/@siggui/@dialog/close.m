function close(hDlg)
%CLOSE Close the dialog figure
%   CLOSE(hDLG) Close the dialog figure.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2009/01/05 18:00:35 $

if isrendered(hDlg),
    
    hFig = get(hDlg, 'FigureHandle');
    
    if ishghandle(hFig),
        
        % Delete the transaction.
        delete(hDlg.Operations);
        
        set(hDlg,'Operations',[]);
        
        delete(hFig);
    end
end

% [EOF]
