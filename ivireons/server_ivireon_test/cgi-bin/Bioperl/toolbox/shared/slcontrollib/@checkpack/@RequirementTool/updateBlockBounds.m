function updateBlockBounds(this) 
%

% UPDATEBLOCKBOUNDS push bound data from visualization to block parameters
%
 
% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/11 20:36:48 $

%Call static method on block dialog class to set block bound properties
%correctly
hBlk = this.Application.DataSource.BlockHandle;
cls = get_param(getFullName(hBlk),'DialogControllerArgs');
ok = feval(strcat(cls,'.setBounds'),hBlk,this.hReq);
if ok
   this.isDirty = false;
end

%Check if there is a block dialog open as this will be in an hasunappliedchages 
%state and preventing the block parameter updates
dlgs = hBlk.getDialogSource.getOpenDialogs;
if ~isempty(dlgs)
   if dlgs{1}.hasUnappliedChanges
      %Prevent the apply from recursively calling the updateVisualization
      this.PreventVisUpdate = true;
      dlgs{1}.apply
      this.PreventVisUpdate = false;
   end
end
end
