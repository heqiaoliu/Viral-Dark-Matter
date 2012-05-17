function stripanchors
%STRIPANCHORS Remove anchors that evaluate MATLAB code from Profiler HTML
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   STRIPANCHORS displays stripped-down HTML from the Profiler in a new
%   HTML window, thereby allowing users to compare two profiling runs
%   without causing problems with stale file information.
%
%   See also PROFVIEW.

%   Copyright 1984-2008 The MathWorks, Inc.

%   $Revision: 1.1.6.8 $  $Date: 2008/12/04 22:39:23 $ 
%   Ned Gulley, Mar 2002

str = char(com.mathworks.mde.profiler.Profiler.getHtmlText);

% The question mark makes the .* wildcard non-greedy
str = regexprep(str,'<a.*?>','');
str = regexprep(str,'</a>','');
str = regexprep(str,'<form.*?</form>','');

str = strrep(str,'<body>','<body bgcolor="#F8F8F8"><strong>Links are disabled because this is a static copy of a profile report</strong><p>');

web('-new', '-noaddressbox', ['text://' str]);