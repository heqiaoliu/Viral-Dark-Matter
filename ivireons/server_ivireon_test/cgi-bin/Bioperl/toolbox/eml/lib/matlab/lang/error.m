function error(varargin)
%Embedded MATLAB Library Function

%   Limitations:  This is an extrinsic call.  

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml.extrinsic('error');
error(varargin{:});