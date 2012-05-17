function setBAILFLWidgets(dlg)
% Update state of the IF+FL optimization choices in the dialog

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $     $Date: 2010/05/20 02:17:51 $

setBAILFLMethodTooltip(dlg);

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
enaTxt = 'inactive';
ena = 'on';

% Define all MSB controls, make them invisible
hAll = [dlg.hBASpecifyPrompt dlg.hBAILFLMethod dlg.hBAILFLValuePrompt...
    dlg.hBAILFLPercent dlg.hBAILFLCount dlg.hBAILFLUnits...
    dlg.hBAILFLSpecifyMSBMagnitude dlg.hBAILFLSpecifyILBits...
    dlg.hBAILFLSpecifyLSBMagnitude dlg.hBAILFLSpecifyFLBits,...
    dlg.hBAILFLGuardBitsPrompt dlg.hBAILFLGuardBits,...
    dlg.hBAILFLExtraBitsPrompt dlg.hBAILFLExtraBits];

set(hAll,'visible','off');

set([dlg.hBASpecifyPrompt dlg.hBAILFLMethod],'visible','on');

switch dlg.BAILFLMethod
  case 1 % maximum Overflow
         % Turn on units
         % Select which edit box to turn on
    if dlg.BAILUnits==1 % Percent
        h = dlg.hBAILFLPercent;
    else % Count
        h = dlg.hBAILFLCount;
    end
    set([h dlg.hBAILFLUnits dlg.hBAILFLGuardBits], ...
        'visible','on','enable',ena);
    set(dlg.hBAILFLGuardBitsPrompt, ...
        'visible','on','enable',enaTxt);
  case 2 % Specify Magnitude
           % Show magtext control
    set([dlg.hBAILFLValuePrompt dlg.hBAILFLGuardBitsPrompt], ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set([dlg.hBAILFLSpecifyMSBMagnitude dlg.hBAILFLGuardBits], ...
        'visible','on','enable',ena);
  case 3 % Integer bits
    
    set(dlg.hBAILFLValuePrompt, ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLSpecifyILBits, ...
        'visible','on','enable',ena);
    
    % Hide guard bits in this mode
    set([dlg.hBAILFLGuardBitsPrompt ...
         dlg.hBAILFLGuardBits],'visible','off');
    
  case 4 % Specify precision
         % Show specify precision controls
       
    set(dlg.hBAILFLValuePrompt, ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLSpecifyLSBMagnitude, ...
        'visible','on','enable',ena);
    
    % Enable extra bits in this mode
    % Choose "extra bits" tooltip based on mode
    tip = DAStudio.message('FixedPoint:fiEmbedded:ExtraFLBitsToolTip');
    set(dlg.hBAILFLExtraBitsPrompt , ...
        'tooltip',tip, ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLExtraBits, ...
        'tooltip',tip, ...
        'visible','on','enable',ena);
    
  case 5 % Fractional bits
    set(dlg.hBAILFLValuePrompt, ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLSpecifyFLBits, ...
        'visible','on','enable',ena);
    
    % Hide extra bits in this mode
    set([dlg.hBAILFLExtraBitsPrompt ...
         dlg.hBAILFLExtraBits],'visible','off');
    
  otherwise
    % Internal message to help debugging. Not intended to be user-visible.
    errID = generatemessageid('unsupportedEnumeration');
    error(errID, 'Invalid Selection (%d)', dlg.BAILFLMethod);
end

    
