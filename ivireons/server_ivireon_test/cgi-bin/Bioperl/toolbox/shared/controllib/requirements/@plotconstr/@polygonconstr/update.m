function update(Constr, varargin)
%UPDATE  Updates constraint display when data changes.
%
%   Main method for updating the display when the constraint
%   data changes.  Issues a DataChanged event to notify all
%   observers that the data changed (no listeners on individual
%   data properties).

%   Author(s): P.Gahinet, A. Stothert
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:00 $

if isa(Constr,'plotconstr.designconstr') && Constr.Activated
   % Protect against illicit calls during undo add
   Constr.updateOverlap;
   Constr.render;         % re-draw constraint
   % Notify observers of data change
   Constr.send('DataChanged')
end
