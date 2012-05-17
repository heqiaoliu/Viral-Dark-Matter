function addIO(this,dlg) 
%
 
% Author(s): A. Stothert 08-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 22:05:16 $

% ADDIO process btnAdddIO events and add a linearization IO to the block

%Get selected items from the Signal Selector widget
selItems = this.hSigSelector.TCPeer.getItems;
nSel     = numel(selItems);
newData  = cell(nSel,4);
mdl      = bdroot(this.getBlock.getFullName);  %Note IOs are from same model as block, no model ref support
for ct = 1:nSel
   newData(ct,:) = {...
      localFormatBlockPath(mdl,selItems{ct}.Source.Block), ...
      selItems{ct}.Source.PortNumber, ...
      'in',...   %linearization IO type
      'off'};    %linearization open-loop setting
end

if nSel
   %Update the block dlg with the newly selected IO
   this.LinearizationIOs = vertcat(this.LinearizationIOs,newData);
   this.isIOModifiedbyDlg = true;
   %Put dialog in dirty state
   dlg.enableApplyButton(true);
   %Update the dialog display
   dlg.refresh
end
end

function name = localFormatBlockPath(mdl,name)
% Helper function to format the raw block path into a path used by the
% block

%Remove any linefeeds in block path
name = regexprep(name,'\n',' ');

%Strip out the model name
name = regexprep(name,strcat('^',mdl),'');
end