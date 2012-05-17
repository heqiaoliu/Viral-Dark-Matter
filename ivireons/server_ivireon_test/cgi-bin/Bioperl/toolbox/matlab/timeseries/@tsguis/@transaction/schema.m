function schema
% Defines properties for @transaction class.
% Extension of transaction to support custom 
% refresh method after undo/redo.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2006/06/27 23:11:33 $

% Register class 
c = schema.class(findpackage('tsguis'),'transaction');

%% Transaction class is overloaded so that timeseries operations on
%% metadata, timeseries and timeseriesArray are stored together. This
%% enables undo and redo to be applied to all operations on timeseries
%% objects as a unit
% Editor data
schema.prop(c,'Name','string'); 
schema.prop(c,'Buffer','MATLAB array');
schema.prop(c,'InitialValue','MATLAB array');
schema.prop(c,'FinalValue','MATLAB array');
% Cell array of handles to the affected timeseries or tscollection object
p = schema.prop(c,'ObjectsCell','MATLAB array'); 
p.FactoryValue = {};
p.SetFunction = @localSetInitialValue;   
 
function propVal = localSetInitialValue(es,ed)

% Set function caches the initial @timeseries value objects

% Make room for additional @timeseries initial values if
% needed
if numel(ed)>numel(es.InitialValue)
   es.InitialValue = [es.InitialValue; ...
                      cell(numel(ed)-numel(es.InitialValue),1)];
end
        
% If a new timeseries has been added to ObjectCell, cache its
% initial value (as a @timeseries value object).
for k=1:length(ed)
    if ~any(cellfun(@(x) x==ed{k},es.ObjectsCell))     
        es.InitialValue{k} = ed{k}.TsValue;
    end
end
propVal = ed;