function schema
%SCHEMA

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:25:36 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'SROTuning',findclass(sisopack,'AutomatedTuningPanel'));

% Public Properties
schema.prop(c,'DesignButton','MATLAB array');   % handle to the design button