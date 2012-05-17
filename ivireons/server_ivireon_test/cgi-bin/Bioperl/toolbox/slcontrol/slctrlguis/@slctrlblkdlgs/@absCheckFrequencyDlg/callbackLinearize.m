function callbackLinearize(this,tag,dlg)
%
 
% Author(s): A. Stothert 09-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 22:05:17 $

% CALLBACKLINEARIZE  manage widget changes on the linearize tab
%

switch tag
   case 'LinearizeAt'
      bSShot = isequal(dlg.getWidgetValue('LinearizeAt'),0);
      dlg.setEnabled('SnapshotTimes',bSShot);
      dlg.setEnabled('TriggerType',~bSShot);
   case 'RateConversionMethod'
      bPrewarp = isequal(dlg.getWidgetValue('RateConversionMethod'),3-1) || ...
         isequal(dlg.getWidgetValue('RateConversionMethod'),6-1);
      dlg.setEnabled('PreWarpFreq',bPrewarp);
   case {'btnIOSelector_Show', 'btnIOSelector_Hide'}
      %Switching widget visibility and explicitly not calling dialog reset,
      %as dialog reset would completely redo layout.
      if this.showSigSelector
         %Switch from showing sig selector to hiding sig selector
         this.showSigSelector = false;
         %Clear any sig selections
         dlg.setWidgetValue('selsigview_signalsTree','')
         this.hSigSelector.selectSignal(dlg)
      else
         %Switch from hiding sig selector to showing sig selector
         this.showSigSelector = true;
      end
      dlg.setVisible('wgtIOSelector',this.showSigSelector)
      dlg.setVisible('txtSigSelector',this.showSigSelector)
      dlg.setVisible('btnIOSelector_Hide',this.showSigSelector)
      dlg.setVisible('btnIOSelector_Show',~this.showSigSelector)
      dlg.setVisible('btnIOSelectorAdd',this.showSigSelector)
      dlg.resetSize
   case 'btnIOSelectorAdd'
      this.addIO(dlg);
   case 'btnIOSelectorRemove'
      this.removeIO(dlg);
   otherwise
      %Nothing to do
end
end