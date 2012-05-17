function setBAFLWidgets(dlg)
% Update state of all Bit Allocation Fraction Length dialog widgets

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $     $Date: 2010/05/20 02:17:50 $

setBAFLMethodTooltip(dlg);

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
enaTxt = 'inactive';
ena = 'on';

% Define all LSB controls, make them invisible
hAll = [dlg.hBAFLValuePrompt dlg.hBAFLPrompt...
    dlg.hBAFLSpecifyMagnitude dlg.hBAFLSpecifyBits];
set(hAll,'visible','off');

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
set(dlg.hBAFLMethod,'visible','on','enable',ena,'value',dlg.BAFLMethod);
set(dlg.hBAFLPrompt,'visible','on','enable',enaTxt);
switch dlg.BAFLMethod
    case 1 % Smallest magnitude
      set(dlg.hBAFLValuePrompt, ...
            'visible','on','enable',enaTxt); % enabled but drag-able
        set(dlg.hBAFLSpecifyMagnitude, ...
            'visible','on','enable',ena);

        % Enable extra bits in this mode
        % Choose "extra bits" tooltip based on mode
        tip = DAStudio.message('FixedPoint:fiEmbedded:ExtraFLBitsToolTip');
        set(dlg.hBAFLExtraBitsPrompt , ...
            'tooltip',tip, ...
            'visible','on','enable',enaTxt); % enabled but drag-able
        set(dlg.hBAFLExtraBits, ...
            'tooltip',tip, ...
            'visible','on','enable',ena);
        
    case 2 % Directly specify number of FL Bits
      set(dlg.hBAFLValuePrompt, ...
            'visible','on','enable',enaTxt); % enabled but drag-able
        set(dlg.hBAFLSpecifyBits, ...
            'visible','on','enable',ena);
        
        % Hide extra bits in this mode
        set([dlg.hBAFLExtraBitsPrompt ...
             dlg.hBAFLExtraBits],'visible','off');

  otherwise
    % Internal message to help debugging. Not intended to be user-visible.
    errID = generatemessageid('unsupportedEnumeration');
    error(errID, 'Invalid BAFLMethod (%d)', dlg.BAFLMethod);
end
