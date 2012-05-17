function schema
%SCHEMA

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:25:16 $

% Register class 
sisopack = findpackage('sisogui');
schema.class(sisopack,'LQGTuning',findclass(sisopack,'AutomatedCompensatorTuning'));

