function initializeLinearizationProps(this,hBlk) 
 
% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 22:05:19 $

% INITIALIZELINEARIZATIONPROPS set dialog properties based on block properties
%

%Initialize object properties that correspond to block properties
this.syncLinIOData;
this.LinearizeAt            = hBlk.LinearizeAt;
this.SnapshotTimes          = hBlk.SnapshotTimes;
this.TriggerType            = hBlk.TriggerType;
this.ZeroCross              = strcmp(hBlk.ZeroCross,'on');
this.SampleTime             = hBlk.SampleTime;
this.RateConversionMethod   = hBlk.RateConversionMethod;
this.PreWarpFreq            = hBlk.PreWarpFreq;
this.UseExactDelayModel     = strcmp(hBlk.UseExactDelayModel,'on');
this.UseFullBlockNameLabels = strcmp(hBlk.UseFullBlockNameLabels,'on');
this.UseBusSignalLabels     = strcmp(hBlk.UseBusSignalLabels,'on');

%Initialize the signal selector widget
opts = slctrlguis.sigselector.Options;
opts.ViewType             = 'DDG';
opts.RootName             = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSigSelectorTitle');
opts.Model                = bdroot(getFullName(hBlk));
opts.InteractiveSelection = true;
opts.BusSupport           = 'wholeonly';
opts.FilterVisible        = false;
opts.AutoSelect           = true;
tc = slctrlguis.sigselector.SigViewTC(opts);
this.hSigSelector         = tc.createView;
this.hSigSelector.Parent  = this;
this.showSigSelector      = false;
%Add listener for IO selector tree selection events
this.hIOTreeListener   = handle.listener(this.hSigSelector,'TreeSelectionEvent',@(hSrc,hData) localEnableIOAdd(hData));
this.isIOModifiedByDlg = true;
end

function localEnableIOAdd(hData)
%Helper function to manage IO tree selection events

% Enable if there is a selection
if hData.TC.isAnyTreeSelection
    hData.Dialog.setEnabled('btnIOSelectorAdd',true);
else
    hData.Dialog.setEnabled('btnIOSelectorAdd',false);   
end
end