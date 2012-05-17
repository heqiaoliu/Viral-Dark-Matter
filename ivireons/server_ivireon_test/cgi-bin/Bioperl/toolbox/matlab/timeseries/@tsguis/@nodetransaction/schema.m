function schema
% Defines properties for @nodetransaction class.
% Incarnation of transaction to support custom 
% refresh method after undo/redo.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/08/20 22:59:52 $

% Register class 
c = schema.class(findpackage('tsguis'),'nodetransaction');

%% Transaction class is overloaded so that timeseries operations on
%% metadata, timeseries and timeseriesArray are stored together. This
%% enables undo and redo to be applied to all operations on timeseries
%% objects as a unit
% Editor data
schema.prop(c,'Name','string'); 
schema.prop(c,'Buffer','MATLAB array'); 

% A cell array to timeseries objects, which are added or removed by single
% a gesture.
% It needs to be a cell arrays because a user could remove or add multiple
% timeseries members to/from a tscollection.
schema.prop(c,'ObjectsCell', 'MATLAB array');

% tscolection handle for which the transaction was recorded
schema.prop(c,'ParentNodeHandle', 'MATLAB array');

% property to indicate if the set of timeseries/tscollection 
% objects were 'added', 'removed', or 'renamed'
% NOTE: these definitions have literal meaning for undo operations. For
% redo, the meaning of 'added'/'removed' would be reversed.
if (isempty(findtype('node_transaction_action')))
   schema.EnumType('node_transaction_action',{'added','removed','renamed'});
end
p = schema.prop(c,'Action','node_transaction_action');

% Property to store auxiliary information to be accessed by undo/redo
% methods for rename action.
%  Store original name and new name in a cell in case of a rename event on the
%  tscollection.
schema.prop(c,'NamePair','MATLAB array');
