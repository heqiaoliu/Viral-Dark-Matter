function schema
% SCHEMA  Defines properties for wavenetoptions class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:14 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'wavenetoptions');

schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.WavenetPropertiesPanel');
schema.prop(c,'jAdvancedButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jNumUnitsEdit','com.mathworks.mwswing.MJTextField');

% radio buttons
schema.prop(c,'jButtonGroup','javax.swing.ButtonGroup');
schema.prop(c,'jAutoRadio','com.mathworks.mwswing.MJRadioButton');
schema.prop(c,'jUserDefinedRadio','com.mathworks.mwswing.MJRadioButton');
schema.prop(c,'jChooseInteractivelyRadio','com.mathworks.mwswing.MJRadioButton');

% UDD objects for parent and advanced props
schema.prop(c,'NlarxPanel','handle'); % handle to owning panel
schema.prop(c,'AdvancedOptions','handle');

% array of listeners 
schema.prop(c,'Listeners','MATLAB array');

% handle to a wavenet object
p = schema.prop(c,'Object','MATLAB array');
p.FactoryValue = wavenet;
