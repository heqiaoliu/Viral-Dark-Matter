function bool = eml_isequal(a,b)
%Embedded MATLAB Library Function

%   Copyright 2005-2008 The MathWorks, Inc.
%#eml

eml_allow_mx_inputs;

% Check for nargin and assert if not correct
eml_assert(nargin==2,'Not enough input arguments.');

% Test equality
bool = eml_const(feval('isequal',a,b));
%----------------------------------------------------
