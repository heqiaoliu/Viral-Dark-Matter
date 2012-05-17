function schema
% Defines properties for @simulinkTsArrayNode class.

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:18:12 $


%% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'tscollectionNode', findclass(p,'tsparentnode'));

%% Public properties
schema.prop(c,'Tscollection','handle');

%% Property used to record the source of the @tscollection for display
%% on the @tscollectionNode panel
schema.prop(c,'History','string');

%% Handle to the Reset Time panel
schema.prop(c,'TimeResetPanel','handle vector');

%% Handle to the tscollection datachange ('datachange') listener
%% which updates the @tscollectionNode 
schema.prop(c,'TsCollListener','handle');

schema.prop(c,'NewPlotPanel','handle vector');