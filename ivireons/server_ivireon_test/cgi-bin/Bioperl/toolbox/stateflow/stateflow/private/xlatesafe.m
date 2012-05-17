function output = xlatesafe(str)
% XLATESAFE   A xlate call for dealing with over-translation.
%   XLATESAFE(STR) passes STR as 'xlatesafe_STR' to xlate() as a workaround 
%   for over-translation problem. On a Japanese Windows machine, it returns 
%   the STR's translation if its translation is in place. Otherwise, it 
%   returns STR itself. On other locales' machines, it returns STR itself. 
%
%   In translation table xlate, the format is:
%   <(fn)xlatesafe_STR
%   >(fn)the translation of STR.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/21 19:19:08 $

if nargin < 1
    error('Stateflow:UnexpectedError','No input string.')
end

origStr = str;

try
    xlateStr = xlate(['xlatesafe_', str]);
    output = strrep(xlateStr, 'xlatesafe_', '');
catch
    output = origStr; 
end