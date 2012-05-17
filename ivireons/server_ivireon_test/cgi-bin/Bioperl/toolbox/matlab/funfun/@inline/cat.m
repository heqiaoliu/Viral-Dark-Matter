function c = cat(varargin)
%CAT    N-D concatenation of inline objects (disallowed)

%   Steven L. Eddins, August 1995
%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2006/12/15 19:27:43 $

error('MATLAB:inline:cat:notAllowed',...
    'Inline functions can''t be concatenated.');
