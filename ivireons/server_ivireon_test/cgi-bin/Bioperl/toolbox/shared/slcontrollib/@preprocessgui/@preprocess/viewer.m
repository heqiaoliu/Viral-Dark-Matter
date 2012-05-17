function viewer(h, owningFrame)
%VIEWER
%
% Author(s): James G. Owen
% Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/22 04:19:57 $

import com.mathworks.toolbox.control.preprocess.*;

% Build GUI
h.javaframe = com.mathworks.toolbox.control.preprocess.Preprocess(owningFrame,h);
h.javaframe.reset(h);

% Window closing callback - need to create frame variable to
% effectively store callback
hdl = handle( h.javaframe, 'callbackproperties' );
set(hdl, 'WindowClosingCallback',{@localClose h});
set(hdl, 'WindowClosedCallback', {@localClose h});
h.Handles = createHandleArray(h);
    
% Display the gui
awtinvoke(h.javaframe,'setVisible',true);

% -------------------------------------------------------------------------
function s = createHandleArray(h)
jh = h.javaframe;

% Callback for data sink panel
s.nodescombo = jh.fNodesCombo;
s.newnodenext = jh.fNewNodeText;
s.newsaveradio = jh.newSaveRadio;
s.existsaveradio = jh.existSaveRadio;
set(handle(s.nodescombo, 'callbackproperties'),'ItemStateChangedCallback',{@localDataRoutingCallback h ...
    s.newsaveradio s.existsaveradio s.newnodenext s.nodescombo}); 
set(handle(s.newsaveradio, 'callbackproperties'),'ItemStateChangedCallback',{@localDataRoutingCallback h ...
    s.newsaveradio s.existsaveradio s.newnodenext s.nodescombo});
set(handle(s.newnodenext, 'callbackproperties'),'FocusLostCallback',{@localDataRoutingCallback h ...
    s.newsaveradio s.existsaveradio s.newnodenext s.nodescombo});

% Exclusion outlier panel
exclpanel = jh.getExclusionPanel;
s.winlentxt = exclpanel.winlenTxt;
s.conftxt = exclpanel.confTxt;

% Exclusion expression panel
s.exclusiontxt = exclpanel.expressionTxt;

% Bounds panel
s.domainlowcombo = exclpanel.fDomainLowCombo;
s.domainhighcombo = exclpanel.fDomainHighCombo;
s.rangelowcombo = exclpanel.fRangeLowCombo;
s.rangehighcombo = exclpanel.fRangeHighCombo;
s.rangehightxt = exclpanel.fRangeHighTextField;
s.rangelowtxt = exclpanel.fRangeLowTextField;
s.domainhightxt = exclpanel.fDomainHighTextField;
s.domainlowtxt = exclpanel.fDomainLowTextField;

% Exclusion flatliane panel
s.flatlinelength = exclpanel.flatlineLength;

% Exclusion checkboxes
s.outliercheck = exclpanel.checkOutliers;
s.flatlinecheck = exclpanel.checkFlatlines;
s.boundscheck = exclpanel.checkBounds;
s.expressioncheck = exclpanel.checkExpression;

% Outlier callbacks
set(handle(s.winlentxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.winlentxt 'Outlierwindow'});
set(handle(s.winlentxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.winlentxt 'Outlierwindow'});
set(handle(s.conftxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.conftxt 'Outlierconf'});
set(handle(s.conftxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.conftxt 'Outlierconf'});

% Expression callback
set(handle(s.exclusiontxt, 'callbackproperties'),'ActionPerformedCallback',{@stringTxtBoxCB h.Exclusion s.exclusiontxt 'Mexpression'});
set(handle(s.exclusiontxt, 'callbackproperties'),'FocusLostCallback',{@stringTxtBoxCB h.Exclusion s.exclusiontxt 'Mexpression'});

% Flatline window length
set(handle(s.flatlinelength, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.flatlinelength 'Flatlinelength'});
set(handle(s.flatlinelength, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.flatlinelength 'Flatlinelength'});

% Bounds callbacks
set(handle(s.domainlowcombo, 'callbackproperties'),'ItemStateChangedCallback',{@ComboCB h.Exclusion s.domainlowcombo 'Xlowstrict' {'off','on'}});
set(handle(s.domainhighcombo, 'callbackproperties'),'ItemStateChangedCallback',{@ComboCB h.Exclusion s.domainhighcombo 'Xhighstrict' {'off','on'}});
set(handle(s.rangelowcombo, 'callbackproperties'),'ItemStateChangedCallback',{@ComboCB h.Exclusion s.rangelowcombo 'Ylowstrict' {'off','on'}});
set(handle(s.rangehighcombo, 'callbackproperties'),'ItemStateChangedCallback',{@ComboCB h.Exclusion s.rangehighcombo 'Yhighstrict' {'off','on'}});
set(handle(s.rangehightxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.rangehightxt 'Yhigh'});
set(handle(s.rangelowtxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.rangelowtxt 'Ylow'});
set(handle(s.domainhightxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.domainhightxt 'Xhigh'});
set(handle(s.domainlowtxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.domainlowtxt 'Xlow'});
set(handle(s.rangehightxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.rangehightxt 'Yhigh'});
set(handle(s.rangelowtxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.rangelowtxt 'Ylow'});
set(handle(s.domainhightxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.domainhightxt 'Xhigh'});
set(handle(s.domainlowtxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.domainlowtxt 'Xlow'});

% Exclusion checkbox callbacks
set(handle(s.outliercheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Exclusion s.outliercheck 'Outliersactive'});
set(handle(s.flatlinecheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Exclusion s.flatlinecheck 'Flatlineactive'});
set(handle(s.boundscheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Exclusion s.boundscheck 'Boundsactive'});
set(handle(s.expressioncheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Exclusion s.expressioncheck 'Expressionactive'});

%% Filter Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detrend panel
fltrpanel = jh.getFilterPanel;
s.detrendcheck = fltrpanel.detrendCheck;
set(handle(s.detrendcheck, 'callbackproperties'),'FocusLostCallback',{@CheckCB h.Filtering s.detrendcheck 'Detrendactive'});
set(handle(s.detrendcheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Filtering s.detrendcheck 'Detrendactive'});
s.constradio = fltrpanel.constRadio;
set(handle(s.constradio, 'callbackproperties'),'FocusLostCallback',{@RadioCB h.Filtering s.constradio 'Detrendtype' 'constant'});
set(handle(s.constradio, 'callbackproperties'),'ActionPerformedCallback',{@RadioCB h.Filtering s.constradio 'Detrendtype' 'constant'});
s.lineradio = fltrpanel.lineRadio;
set(handle(s.lineradio, 'callbackproperties'),'FocusLostCallback',{@RadioCB h.Filtering s.lineradio 'Detrendtype' 'line'});
set(handle(s.lineradio, 'callbackproperties'),'ActionPerformedCallback',{@RadioCB h.Filtering s.lineradio 'Detrendtype' 'line'});

% First order filter panel
s.firstordtimeconstTxt = fltrpanel.firstOrderTimeConstTxt;
set(handle(s.firstordtimeconstTxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.firstordtimeconstTxt 'Timeconst'});
set(handle(s.firstordtimeconstTxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.firstordtimeconstTxt 'Timeconst'});

% Transfer function panel
s.acoeffs = fltrpanel.AcoeffTxt;
set(handle(s.acoeffs, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.acoeffs 'Acoeffs'});
set(handle(s.acoeffs, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.acoeffs 'Acoeffs'});
s.bcoeffs = fltrpanel.BcoeffTxt;
set(handle(s.bcoeffs, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.bcoeffs 'Bcoeffs'});
set(handle(s.bcoeffs, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.bcoeffs 'Bcoeffs'});

% Ideal filter panel
s.freqrangetxt = fltrpanel.freqRangeTxt;
set(handle(s.freqrangetxt, 'callbackproperties'),'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.freqrangetxt 'Range'});
set(handle(s.freqrangetxt, 'callbackproperties'),'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.freqrangetxt 'Range'});
s.passstopcombo = fltrpanel.passstopCombo;
set(handle(s.passstopcombo, 'callbackproperties'),'ItemStateChangedCallback', ...
    {@ComboCB h.Filtering s.passstopcombo 'Band' {'pass','stop'}});

% Filter type combo
s.filterselectcombo = fltrpanel.filterSelectCombo;
set(handle(s.filterselectcombo, 'callbackproperties'),'ItemStateChangedCallback', ...
    {@ComboCB h.Filtering s.filterselectcombo 'Filter' {'firstord','transfer' 'ideal'}});

% Filtering check box
s.filteringcheck = fltrpanel.filteringCheck;
set(handle(s.filteringcheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Filtering s.filteringcheck 'Filteractive'});
set(handle(s.filteringcheck, 'callbackproperties'),'FocusLostCallback',{@CheckCB h.Filtering s.filteringcheck 'Filteractive'});


%% Interp Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interppanel = jh.getInterPanel;
s.removecheck = interppanel.removeCheck;
s.missingcheck = interppanel.missingCheck;
s.interpcombo = interppanel.interpCombo;
s.alloranycombo = interppanel.alloranyCombo;
set(handle(s.removecheck, 'callbackproperties'),'FocusLostCallback',{@CheckCB h.Interp s.removecheck 'Rowremove'});
set(handle(s.removecheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Interp s.removecheck 'Rowremove'});
set(handle(s.missingcheck, 'callbackproperties'),'FocusLostCallback',{@CheckCB h.Interp s.missingcheck 'Interpolate'});
set(handle(s.missingcheck, 'callbackproperties'),'ItemStateChangedCallback',{@CheckCB h.Interp s.missingcheck 'Interpolate'});
%set(s.alloranycombo,'FocusLostCallback',{@ComboCB h.Interp s.alloranycombo 'Rowor' {'off','on'}});
set(handle(s.alloranycombo, 'callbackproperties'),'ItemStateChangedCallback',{@ComboCB h.Interp s.alloranycombo 'Rowor' {'off','on'}});
set(handle(s.interpcombo, 'callbackproperties'),'ItemStateChangedCallback',{@ComboCB h.Interp s.interpcombo 'method' {'zoh','Linear'}});

% ----------------------------------------------------------------------------
function numericTxtBoxCB(~,~,h,javaTxt,prop)
% Text box callback for numeric property change detection
try
   txtstr = char(javaTxt.getText);
   if ~isempty(txtstr)     
      newval = eval(char(javaTxt.getText));
   else
      newval = h.findprop(prop).FactoryValue; 
      javaTxt.setText(num2str(newval));
   end
   set(h,prop,newval);
catch E % Put back previous value 
   msg = ['You must specify either a numeric value or a MATLAB expression for ', ...
               h.findprop(prop).Description]; 
   msgbox(msg,'Data Preprocessing Tool','modal');
   val = get(h,prop);
   % R.C. allow logical values to be displayed
   if isnumeric(val) || islogical(val)
       if length(val)==1
          javaTxt.setText(sprintf('%0.3g',val));
       elseif length(val)>1
          javaTxt.setText(['[' num2str(val) ']']);
       end
   elseif ischar(val)
       javaTxt.setText(val);
   end
end

function stringTxtBoxCB(~,~,h,javaTxt,prop)
% Text box callback for exclsuio property change detection
set(h,prop,char(javaTxt.getText));


function ComboCB(~,~,h,javaCombo,prop,vals)
% Combo box callback
set(h,prop,vals{double(javaCombo.getSelectedIndex)+1});


function CheckCB(~,~,h,javaCheck,prop)
% The oulier removal checkbox callback
vals = {'off','on'};
set(h,prop,vals{javaCheck.isSelected+1});


function RadioCB(~,~,h,radio,prop,val)
if radio.isSelected
    set(h,prop,val);
end


function localClose(~,~,h)
% Window closing callback
if ~isempty(h) && ishandle(h)
  h.close;
end


function localDataRoutingCallback(~,~,h,~,existSaveRadio, ...
   fNewNodeText,fNodesCombo)
% Callback for changes to data sink
if ~isempty(h) && ishandle(h)
    if existSaveRadio.isSelected
        h.TargetNode = char(fNodesCombo.getSelectedItem);
    else
        h.TargetNode = char(fNewNodeText.getText);
    end
end
