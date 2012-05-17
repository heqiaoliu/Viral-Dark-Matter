function result = sf_rtw(commandName, varargin)
% SF_RTW Extract Stateflow information required for RTW build for 
% Stateflow versions 1.1 and above
%
%   SF_RTW is called from inside TLC to extract the necessary
%   Stateflow information which is required for the RTW build.
%   In particular, RTW needs to know the unique names that Stateflow
%   uses for its input data, output data, input events, output
%   events, chart workspace data, and machine workspace data.  The
%   underlying motivation is that RTW must create a list of hash
%   defines for Stateflow since RTW creates these data under a
%   different name.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.22.2.5 $

result = sf('Private', 'sf_rtw', commandName, varargin{:});

