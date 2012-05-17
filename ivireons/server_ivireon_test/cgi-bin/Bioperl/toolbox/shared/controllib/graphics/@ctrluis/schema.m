function schema
% SCHEMA Creates package for Response Plot package.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:12 $

p = schema.package('ctrluis');
p.Documented = 'off';

% schema.UserType('NormalizedPosition','MATLAB array',@LocalCheckPosition);


%-------------- Local functions -----------------------------------

% function LocalCheckPosition(NewPos)
% % Checks for position value in normalized units
% NewPos = NewPos(:);
% if ~isequal(size(NewPos),[4 1])
%     error('Position must be a 4-entry vector')
% else
%     NewPos = [NewPos(1:2) ; NewPos(1:2)+NewPos(3:4)];
%     if any(NewPos<0) | any(NewPos>1)
%         error('Position must be specified in normalized units.')
%     end
% end