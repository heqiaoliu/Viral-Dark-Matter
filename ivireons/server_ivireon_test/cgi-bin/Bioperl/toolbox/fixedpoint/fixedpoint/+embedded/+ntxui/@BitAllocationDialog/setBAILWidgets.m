function setBAILWidgets(dlg)
% Update state of all Bit Allocation Integer Length dialog widgets

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:17:53 $

setBAILMethodTooltip(dlg);

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
enaTxt = 'inactive';
ena = 'on';

% Define all MSB controls, make them invisible
hAll = [dlg.hBAILValuePrompt dlg.hBAILPrompt dlg.hBAILPercent ...
    dlg.hBAILCount dlg.hBAILUnits ...
    dlg.hBAILSpecifyMagnitude dlg.hBAILSpecifyBits];
set(hAll,'visible','off');

set(dlg.hBAILMethod,'visible','on','enable',ena,'value',dlg.BAILMethod);
set(dlg.hBAILPrompt,'visible','on','enable',enaTxt);
switch dlg.BAILMethod
  case 1 % Maximum Overflow
         % Turn on units
         % Select which edit box to turn on
    if dlg.BAILUnits==1 % Percent
        h = dlg.hBAILPercent;
    else % Count
        h = dlg.hBAILCount;
    end
    set([h dlg.hBAILUnits dlg.hBAILGuardBits], ...
        'visible','on','enable',ena);
    set(dlg.hBAILGuardBitsPrompt, ...
        'visible','on','enable',enaTxt);
    
  case 2 % Specify Magnitude
         % Show magtext control
    set([dlg.hBAILValuePrompt dlg.hBAILGuardBitsPrompt], ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set([dlg.hBAILSpecifyMagnitude dlg.hBAILGuardBits], ...
        'visible','on','enable',ena);
    
  case 3 % Directly specify number of IL Bits
    set(dlg.hBAILValuePrompt, ...
        'visible','on','enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILSpecifyBits, ...
        'visible','on','enable',ena);
    
    % Hide guard bits in this mode
    set([dlg.hBAILGuardBitsPrompt ...
         dlg.hBAILGuardBits],'visible','off');
    
  otherwise
    errID = 'FixedPoint:fiEmbedded:unsupportedEnumeration';
    error(errID,'Invalid BAILMethod (%d)', dlg.BAILMethod);
end
