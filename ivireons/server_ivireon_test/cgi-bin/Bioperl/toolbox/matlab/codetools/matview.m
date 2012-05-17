function matview(filename,varname,basevarsuffix)
%MATVIEW Display a variable from a MAT-file in the Variable Editor
%   MATVIEW(filename,varname) opens the Variable Editor showing the value
%   of the specified variable in the specified MAT-file.

% Copyright 2007-2010 The MathWorks, Inc.

    if nargin<3
        basevarsuffix = '';
    end
    
    comparisons_private('matview',filename,varname,basevarsuffix);
end




