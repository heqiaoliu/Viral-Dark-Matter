function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2005 The MathWorks, Inc. 

% Do not generate any code for baselines since the functions that create
% baselines like bar and stem will make sure they get the right values.
% This means if you create a baseline outside of a bar or stem plot it
% will not have any code generated for it. See plotutils.m for a way
% to generate mcode for a baseline.