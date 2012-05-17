function schema
% Defines properties for @transaction class.
% Extension of transaction to support custom 
% refresh method after undo/redo.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/08/20 22:59:45 $

% Register class 
c = schema.class(findpackage('tsguis'),'colltransaction');

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
% timeseries members to/from a tscollection
schema.prop(c,'TimeseriesCell', 'MATLAB array');

% tscolection handle for which the transaction was recorded
schema.prop(c,'TscollectionHandle', 'MATLAB array');

% property to indicate if timeseries objects were added or removed 
schema.prop(c,'WasRemoved','MATLAB array');
 
