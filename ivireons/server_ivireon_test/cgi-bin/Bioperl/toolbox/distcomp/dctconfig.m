function config = dctconfig(varargin)
%DCTCONFIG has been deprecated. Please use pctconfig
%
%    The DCTCONFIG function has been deprecated and will be removed in 
%    the next version of the Parallel Computing Toolbox. Please use the
%    PCTCONFIG function instead
%
%    CONFIG = DCTCONFIG() returns a struct, CONFIG, of the configuration 
%    property names and values.
%
%    CONFIG = DCTCONFIG('P1', V1, 'P2', V2,...) configures the properties 
%    of the Parallel Computing Toolbox which are passed as 
%    parameter/value pairs, P1, V1, P2, V2.  The parameter/value pairs can 
%    be specified as a cell array or a struct.  The function then returns a 
%    struct, CONFIG, of the configuration property names and values.
%  
%    If the property is 'port', the specified value is used to set the
%    port for the client session of the Parallel Computing Toolbox.
%
%    If the property is 'pmodeport', the specified value is used to set the
%    port for the communications with the labs in a PMODE session. 
%
%    If the property is 'hostname', the specified value is used to set the
%    hostname for the client session of the Parallel Computing Toolbox.
%
%  See Also: pctconfig

% Copyright 2004-2007 The MathWorks, Inc.
  
warning('distcomp:dctconfig:DeprecatedFunction', ...
    ['The dctconfig function is deprecated and will be removed in the\n' ...
    'next version of the Parallel Computing Toolbox. Please use the\n' ...
    'pctconfig function instead.']);
warning('off', 'distcomp:dctconfig:DeprecatedFunction');

% Call the replacement pctconfig function
config = pctconfig(varargin{:});