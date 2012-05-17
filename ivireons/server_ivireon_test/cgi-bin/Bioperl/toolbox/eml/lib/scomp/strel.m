function obj = strel(varargin)
%Embedded MATLAB Library function.
% Implement strel function.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 15:22:12 $
%#eml

eml_allow_mx_inputs;
eml_transient;
eml_must_inline;

obj = eml_const(feval('strel',varargin{:}));

