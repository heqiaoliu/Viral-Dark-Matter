function schema
%SCHEMA  Defines properties for @AutomatedTuning class, which handle all
%the automated tuning features provided in SISOTOOL

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/02/06 19:50:27 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'AutomatedTuning');

% Public Properties
schema.prop(c,'Parent','handle');               % handle to @sisotool
schema.prop(c,'MainPanel','MATLAB array');      % handle to the main panel
schema.prop(c,'CardPanel','MATLAB array');      % handle to the card panel
schema.prop(c,'MethodCombo','MATLAB array');    % handle to the method combo
schema.prop(c,'IdxMethod','MATLAB array');      % index of selected automated tuning method
schema.prop(c,'MethodManagers','MATLAB array'); % available automated tuning methods