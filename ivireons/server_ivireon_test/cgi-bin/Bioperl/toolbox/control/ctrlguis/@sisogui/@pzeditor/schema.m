function schema
%SCHEMA  Defines properties for @pzeditor class, which allows user to tune
%gain/pole/zero of any compensator manually

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2007/02/06 19:50:57 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'pzeditor');

% Data properties
schema.prop(c,'CompList','MATLAB array');       % Handle to Dynamic Compensator objects excluding Pure Gain objects
schema.prop(c,'GainList','MATLAB array');       % Handle to Pure Gain Compensator objects

schema.prop(c,'idxC','MATLAB array');           % Index to selected compensator object in CompList
schema.prop(c,'idxCold','MATLAB array');        % Index to previous selected compensator object in CompList
schema.prop(c,'idxPZ','MATLAB array');          % Indices to selected pzgroup object in the selected compensator object
schema.prop(c,'GainCache','MATLAB array');      % Copy of the compensator gain
schema.prop(c,'Handles','MATLAB array');        % Array of the handles to objects of GUI
schema.prop(c,'Parent','handle');               % Parent object (@sisotool)
schema.prop(c,'LoopData','handle');             % Central data repository

% Public properties
schema.prop(c,'FrequencyUnits','string');       % Frequency units
schema.prop(c,'PrecisionFormat','string');      % Format string for sprintf

% Private properties
p = schema.prop(c,'Listeners','handle vector'); % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

% Hidden modes
% EditMode: [{off}|idle]
p = schema.prop(c,'EditMode','string');       
set(p,'AccessFlags.PublicSet','off','AccessFlags.Init','on','FactoryValue','off');