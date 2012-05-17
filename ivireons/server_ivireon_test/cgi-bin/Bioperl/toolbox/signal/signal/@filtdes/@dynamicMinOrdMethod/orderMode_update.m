function orderMode_update(h,ft)
%ORDERMODE_UPDATE Update the order mode property.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:36:10 $

constr = findConstr(h,ft,'minimum');

if isempty(constr),
    % Disable orderMode
    enabdynprop(h,'orderMode','off');
else
    % Enable orderMode
    enabdynprop(h,'orderMode','on');
end
