function c = horzcat(varargin)
%HORZCAT Horizontal concatenation of inline objects (disallowed)

%   Steven L. Eddins, August 1995
%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2006/12/15 19:27:45 $

error('MATLAB:inline:horzcat:notAllowed', ...
    'Inline functions can''t be concatenated.');
