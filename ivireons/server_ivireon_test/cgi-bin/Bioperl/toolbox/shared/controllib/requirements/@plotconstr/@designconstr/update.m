function update(Constr, varargin)
%UPDATE  Updates constraint display when data changes.
%
%   Main method for updating the display when the constraint
%   data changes.  Issues a DataChanged event to notify all
%   observers that the data changed (no listeners on individual
%   data properties).

%   Author(s): P.Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:58 $

for idx = 1:numel(Constr)
   if isa(Constr,'plotconstr.designconstr') && Constr(idx).Activated
      % Protect against illicit calls during undo add
      Constr(idx).render;  % rerender
      % Notify observers of data change
      Constr(idx).send('DataChanged')
   end
end