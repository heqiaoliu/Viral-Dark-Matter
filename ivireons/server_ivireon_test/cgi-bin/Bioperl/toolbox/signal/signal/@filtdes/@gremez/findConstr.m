function consStr = findConstr(h,ft,orderMode)
%FINDCONSTR Find the appropriate constructor.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:07:13 $

% This method is overloaded so that it can intercept 'minimum even' and
% 'minimum odd' OrderModes.  We can probably change this to:

% if nargin > 2 && any(strcmpi(orderMode, 'minimum even', 'minimum odd')),
%     orderMOde = 'minimum';
% end
% consStr = super::findConstr(h, ft, orderMode);

s = get(h,'availableTypes');

indx = findConstrIndx(h,ft);

if nargin < 3,
    orderMode = 'specify';
elseif any(strcmpi(orderMode, {'minimum even', 'minimum odd'})),
    orderMode = 'minimum';
end

% Return constructor
consStr = getfield(s(indx).construct,orderMode);

% [EOF]
