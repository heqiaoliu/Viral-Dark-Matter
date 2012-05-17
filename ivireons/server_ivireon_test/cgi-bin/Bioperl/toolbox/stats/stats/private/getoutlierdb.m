function theoutlierdb=getoutlierdb(varargin)

%   $Revision: 1.1.8.1 $
%   Copyright 2003-2004 The MathWorks, Inc.

theoutlierdb = dfgetset('theoutlierdb');

% Create a singleton class instance
if isempty(theoutlierdb)
   theoutlierdb = stats.outlierdb;
   dfgetset('theoutlierdb',theoutlierdb);
end
