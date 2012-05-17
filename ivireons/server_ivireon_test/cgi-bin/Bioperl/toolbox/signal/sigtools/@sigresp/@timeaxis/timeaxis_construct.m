function allPrm = timeaxis_construct(this, varargin)
%TIMEAXIS_CONSTRUCT

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:30:06 $

allPrm = this.super_construct(varargin{:});

createparameter(this, allPrm, 'Normalized Frequency', 'freqmode', 'on/off', 'on');
createparameter(this, allPrm, 'Plot Type', 'plottype', ...
    {'Line with Marker', 'Stem', 'Line'}, 'Stem');

% hPrm = getparameter(this, 'freqmode');
% l = [ ...
%         handle.listener(hPrm, 'NewValue', @lcltimemode_listener); ...
%         handle.listener(hPrm, 'UserModified', @lcltimemode_listener); ...
%     ];
% set(l, 'CallbackTarget', this);
% set(this, 'Listeners', l);
% 
% timemode_listener(this, []);

% -------------------------------------------------------------------------
function lcltimemode_listener(this, eventData)

timemode_listener(this, eventData);

% [EOF]
