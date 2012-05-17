function btn = showdialog(msgtype, varargin)
%SHOWDIALOG(DLGTYPE, MSGTYPE)

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2010/05/13 17:29:34 $

btn = '';
%define constants
TYPE_ERROR = 'Error';
TYPE_WARNING = 'Warning';
TYPE_QUESTION = '';
BTN_YES = DAStudio.message('FixedPoint:fixedPointTool:labelYes');
BTN_NO = DAStudio.message('FixedPoint:fixedPointTool:labelNo');
BTN_TEST = BTN_YES;
select = DAStudio.message('FixedPoint:fixedPointTool:labelEnableSignalLogging');
title = '';

switch msgtype
  case 'ploterror'
    dlgtype = TYPE_ERROR;
    title_ID = 'FixedPoint:fixedPointTool:errorTitlePlotError';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgPlotError');

  case 'diffploterror'
    dlgtype = TYPE_ERROR;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleDiffPlotError';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgDiffPlotError');
  case 'histploterror'
    dlgtype = TYPE_ERROR;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleHistPlotError';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgHistPlotError');
  case 'proposedtinvalid'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleProposedDT';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgProposedDTinvalid', varargin{:});
  case 'scaleproposefailed'
    dlgtype = TYPE_ERROR;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleScaleProposeFailed';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgScaleProposeFailed');
  case 'scaleproposeattention'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:titleProposeFLNeedsAttention';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgProposeFLNeedsAttention');    
  case 'scaleapplyattention'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:titleApplyFLNeedsAttention';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgApplyFLNeedsAttention');  
    BTN_IGNORE_AND_APPLY = DAStudio.message('FixedPoint:fixedPointTool:btnIgnoreAlertAndApply');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    btns = {BTN_IGNORE_AND_APPLY,BTN_CANCEL};
    btndefault = BTN_CANCEL;
    BTN_TEST = varargin{1};
  case 'scaleapplyfailed'
    dlgtype = TYPE_ERROR;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleScaleApplyFailed';
    title = DAStudio.message(title_ID);
    if isempty(varargin)
        arg = '';
    else
        arg = varargin{1};
    end
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgScaleApplyFailed', arg);
  case 'noselection'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleNoSelection';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoSelection');
  case 'noselectionscaleinfo'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleNoSelection';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoSelectionScaleInfo');

  case 'noselectionhighlight'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleNoSelection';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoSelectionHighlight');

  case 'noselectionhighlightdtgroup'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleNoSelection';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoSelectionHighlightDTGroup');

  case 'notplottable'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleNotPlottable';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNotPlottable', select);

  case 'diffnotplottable'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleDiffNotPlottable';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgDiffNotPlottable');

  case 'histnotplottable'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:errorTitleHistNotPlottable';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgHistNotPlottable', select);

  case 'notacceptchecked'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleApplyFL';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNotAcceptChecked');

  case 'noscalingdata'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleProposeFL';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoScalingData');

  case 'noproposedfl'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleApplyFL';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoProposedFL');

  case 'noproposeddt'
    dlgtype = TYPE_WARNING;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleApplyFL';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgNoProposedDT');

  case 'overwriteresultsReference'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleOverwriteResultsReference';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgOverwriteResultsReference');
    btns = {BTN_YES  BTN_NO};
    btndefault = BTN_YES;
    BTN_TEST = varargin{1};
    
  case 'overwriteresultsActive'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleOverwriteResultsActive';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgOverwriteResultsActive');
    btns = {BTN_YES  BTN_NO};
    btndefault = BTN_YES;
    BTN_TEST = varargin{1};
    
  case 'scalingfixdt'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleProposeFL';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgScalingFixdt');
    btns = {BTN_YES  BTN_NO};
    btndefault = BTN_NO;

  case 'proposedtsharedwarning'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleProposedDT';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgProposedDTshared');
    BTN_CHANGE_ALL = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeAll');
    BTN_CHANGE_THIS = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeThis');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedCancel');
    btns = {BTN_CHANGE_ALL  BTN_CHANGE_THIS BTN_CANCEL};
    btndefault = BTN_CHANGE_ALL;
    BTN_TEST = varargin{1};
    
  case 'ignoreproposalsandsimwarning'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:warningTitleIgnoreProposedDTAndSim';
    title = DAStudio.message(title_ID);
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgIgnoreProposedDTAndSim');
    BTN_SIM = DAStudio.message('FixedPoint:fixedPointTool:btnIgnoreandSimulate');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    btns = {BTN_SIM BTN_CANCEL};
    btndefault = BTN_SIM;
    BTN_TEST = varargin{1};
    
  case 'simmodewarning'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:simmodewarning';
    title = DAStudio.message('FixedPoint:fixedPointTool:simmodewarning');
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgsimmodewarning');
    BTN_CHANGE_SIM_MODE = DAStudio.message('FixedPoint:fixedPointTool:btnChangeSimModeAndContinue');
    BTN_NO = DAStudio.message('FixedPoint:fixedPointTool:labelNo');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    btns = {BTN_CHANGE_SIM_MODE  BTN_NO BTN_CANCEL};
    btndefault = BTN_CHANGE_SIM_MODE;
    BTN_TEST = varargin{1};
    
  case 'proposedtsimmodewarning'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:proposedtsimmodewarning';
    title = DAStudio.message('FixedPoint:fixedPointTool:proposedtsimmodewarning');
    msg = DAStudio.message('FixedPoint:fixedPointTool:msgproposedtsimmodewarning');
    BTN_CHANGE_SIM_MODE = DAStudio.message('FixedPoint:fixedPointTool:btnChangeSimModeAndContinue');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    btns = {BTN_CHANGE_SIM_MODE BTN_CANCEL}; 
    btndefault = BTN_CHANGE_SIM_MODE;
    BTN_TEST = varargin{1};
    
  case 'instrumentationsimmodewarning'
    dlgtype = TYPE_QUESTION;
    title_ID = 'FixedPoint:fixedPointTool:instrumentationsimmodewarning';
    title = DAStudio.message('FixedPoint:fixedPointTool:instrumentationsimmodewarning');
    msg = DAStudio.message('FixedPoint:fixedPointTool:msginstrumentationsimmodewarning');
    BTN_CHANGE_SIM_MODE = DAStudio.message('FixedPoint:fixedPointTool:btnChangeSimModeAndContinue');
    BTN_NO = DAStudio.message('FixedPoint:fixedPointTool:labelNo');
    btns = {BTN_CHANGE_SIM_MODE  BTN_NO};
    btndefault = BTN_CHANGE_SIM_MODE;
    BTN_TEST = varargin{1};
end


me = fxptui.getexplorer;
%cache away the titles of the dialogs so that we can destroy them later if they are still open.
if ~isempty(me) && ~me.istesting
    me.cachedWarningTitles{end+1} = title;
end

%if we're calling showdialog from MATLAB and not the UI make sure we show
%the dialogs
if(isempty(me))
  me.istesting = false;
end

switch dlgtype
  case TYPE_ERROR
    %if we're testing don't launch modal dialog, output to command window
    if(me.istesting)
        fpt_exception = MException(title_ID,title);
      throw(fpt_exception);
    else
      %launch error dialog
      if (nargin > 1) && isa(varargin{1},'MException')
          msg = sprintf('%s %s\n', msg,varargin{1}.message);
      end
      errordlg(msg, title, 'modal');
    end

  case TYPE_WARNING
    %if we're testing don't launch modal dialog, output to command window
    if(me.istesting)
      %output warning to command window
      warning(title_ID,title);
    else
      %launch warning dialog
      warndlg(msg, title, 'modal');
    end

  case TYPE_QUESTION
    %if we're testing don't launch modal dialog, output to command window
    if(me.istesting)
        %turn backtrace off while the model is running.
        h.userdata.warning.backtrace = warning('backtrace');
        warning('off', 'backtrace');
        %output warning to command window
        warning(title_ID,title);
        %restore the state of backtrace when the model stops running
        state = h.userdata.warning.backtrace.state;
        warning(state, 'backtrace');
        btn = BTN_TEST; 
    else
        btn = questdlg(msg, title, btns{:}, btndefault);
        drawnow;
    end
end

%-------------------------------------------------------------------
% [EOF]
