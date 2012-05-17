function out = openmdl(filename)
%OPENMDL   Open *.MDL model in Simulink.  Helper function for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2009/11/13 04:37:17 $

if nargout, out = []; end

if exist('open_system','builtin')
    evalin('base', ['open_system(''' strrep(filename, '''','''''') ''');'] );
else
    error('MATLAB:openmdl:ExecutionError', 'Simulink is not installed.')
end
