function p = isequal(varargin)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
p = eml_isequal_core(false,varargin{:});