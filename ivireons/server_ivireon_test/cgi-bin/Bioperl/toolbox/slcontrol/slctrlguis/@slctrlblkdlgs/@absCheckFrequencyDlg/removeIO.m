function removeIO(this,dlg)
%
 
% Author(s): A. Stothert 08-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:42 $

% REMOVEIO process btnIORemove events and remove an IO from the block
%

iRow = dlg.getSelectedTableRows('tblIOs')+1; %One based indexing for Matlab
if (numel(iRow) > 0 ) && all(iRow > 0 & iRow <= size(this.LinearizationIOs,1))
   %Update the block dlg with the newly selected IO
   this.LinearizationIOs(iRow,:) = [];
   this.isIOModifiedbyDlg = true;
   %Put dialog in dirty state
   dlg.enableApplyButton(true);
   %Update the dialog display
   dlg.refresh
end
end
