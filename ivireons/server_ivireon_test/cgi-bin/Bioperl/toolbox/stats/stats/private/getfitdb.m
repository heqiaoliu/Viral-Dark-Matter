function fitdb=getfitdb(varargin)
% GETFITDB A helper function for DFITTOOL

% $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:38 $
% Copyright 2003-2004 The MathWorks, Inc.

thefitdb = dfgetset('thefitdb');

% Create a singleton class instance
if isempty(thefitdb)
   thefitdb = stats.fitdb;
end

dfgetset('thefitdb',thefitdb);
fitdb=thefitdb;
