function launch(this, launchWhat) 
% LAUNCH gateway to launch various view related dialogs
%
 
% Author(s): A. Stothert 20-May-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:46 $

switch launchWhat
   case {'boundproperties'}
      this.Application.Visual.showDlgTab('tabBounds');
   case 'editbound'
      if ~isempty(this.hReq) && ishandle(this.hReq(1))
         this.hEditDlg.show(this.hReq(1).TextEditor)
      end
   case 'newbound'
      editconstr.newdlg.getInstance(this.Application.Visual,this.Application.Parent);
end
end
