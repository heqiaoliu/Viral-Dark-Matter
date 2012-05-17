function thedsdb=getdsdb(varargin)

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:37 $
%   Copyright 2003-2004 The MathWorks, Inc.

thedsdb = dfgetset('thedsdb');

% Create a singleton class instance
if isempty(thedsdb)
   thedsdb = stats.dsdb;
   dfgetset('thedsdb',thedsdb);
end


