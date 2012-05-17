function this = soscustomreorder
%SOSCUSTOMREORDER   Construct a SOSCUSTOMREORDER object.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 08:17:00 $

this = siggui.soscustomreorder;

labels = { ...
    fdatoolmessage('UseNumeratorOrder'), ...
    fdatoolmessage('SpecifyLabel')};
hden = siggui.selectorwvalues('', {'use','specify'}, labels);
hsv  = siggui.selectorwvalues('', {'use','specify'}, labels);
set(hden, 'Tag', 'denominator', 'Values', {'', this.DenominatorOrder}, 'HiddenValues', 1);
set(hsv, 'Tag', 'scalevalues', 'Values', {'', this.ScaleValuesOrder}, 'HiddenValues', 1);

addcomponent(this, [hden hsv]);

l = handle.listener([hden hsv], 'NewSelection', @newselection_listener);
set(l, 'CallbackTarget', this);
set(this, 'Listener', l);

% -------------------------------------------------------------------------
function newselection_listener(this, ~)

send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% [EOF]
