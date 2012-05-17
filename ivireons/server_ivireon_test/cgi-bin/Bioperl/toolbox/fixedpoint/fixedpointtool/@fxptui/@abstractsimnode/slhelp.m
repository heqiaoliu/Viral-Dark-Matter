function slhelp(this,handle)
%SLHELP   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:50 $

hDlgSource=this.getDialogSource;
if ~isempty(hDlgSource) && ismethod(hDlgSource,'slhelp')
    hDlgSource.slhelp(handle);
end


% [EOF]

