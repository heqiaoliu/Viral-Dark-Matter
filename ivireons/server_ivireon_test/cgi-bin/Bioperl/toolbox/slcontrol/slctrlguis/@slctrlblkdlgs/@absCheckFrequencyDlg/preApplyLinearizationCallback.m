function [status, errmsg] = preApplyLinearizationCallback(this, dlg) 
 
% Author(s): A. Stothert 12-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:41 $

% PREAPPLYLINEARIZATIONCALLBACK  manage preapply callback actions for the
% linearization tab
%

if ~isa(this.LinearizationIOs,'linearize.IOPoint')
   %Linearization IO data defined directly in the block, and not by workspace 
   %variable
   
   %Synchronize the dialog table data with the LinearizationIOs dialog
   %property. As the dialog can only modify the port type and open-loop
   %setting just need to check these. Add/remove IO port is handled in the
   %addIO/removeIO dialog methods respectively
   
   for ct=1:size(this.LinearizationIOs,1)
      %Get table data
      type  = dlg.getTableItemValue('tblIOs',ct-1,2-1); %zero based indexing
      oloop = dlg.getTableItemValue('tblIOs',ct-1,3-1);
      
      %Convert table data to appropriate block data
      switch type
         case ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementInput')
            type = 'in';
         case ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementOutput')
            type = 'out';
         case ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementInputOutput')
            type = 'inout';
         case ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementOutputInput')
            type = 'outin';
         case ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementNone')
            type = 'none';
      end
      if strcmp(oloop,'1'), oloop = 'on';
      else oloop = 'off'; end
      
      %Set dialog data based on table 
      this.LinearizationIOs{ct,3} = type;
      this.LinearizationIOs{ct,4} = oloop;
   end
end

%Set return arguments
status = true;
errmsg = '';
end