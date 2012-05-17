function varargout = createCheckDlg(hBlk,classname) 
 
% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:38 $

% CREATECHECKDLG  static package function to open check block dialog
%

if nargout
    [varargout{1:nargout}] = feval(classname, hBlk);
else
    feval(classname, hBlk);
end
end