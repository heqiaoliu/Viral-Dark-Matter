%STRREP Replace string with another.
%   MODIFIEDSTR = STRREP(ORIGSTR,OLDSUBSTR,NEWSUBSTR) replaces all 
%   occurrences of the string OLDSUBSTR within string ORIGSTR with the
%   string NEWSUBSTR.
%
%   Notes:
%
%   * STRREP accepts input combinations of single strings, strings in 
%     scalar cells, and same-sized cell arrays of strings. If any inputs 
%     are cell arrays, STRREP returns a cell array. 
%
%   * STRREP does not find empty strings for replacement. That is, when
%     ORIGSTR and OLDSUBSTR both contain the empty string (''), STRREP does
%     not replace '' with the contents of NEWSUBSTR.
%
%   Examples:
%
%   % Example 1: Replace text in a character array.
%
%       claim = 'This is a good example';
%       new_claim = strrep(claim, 'good', 'great')
%
%       new_claim = 
%       This is a great example.
%
%   % Example 2: Replace text in a cell array.
%
%       c_files = {'c:\cookies.m'; ...
%                  'c:\candy.m';   ...
%                  'c:\calories.m'};
%       d_files = strrep(c_files, 'c:', 'd:')
%
%       d_files = 
%           'd:\cookies.m'
%           'd:\candy.m'
%           'd:\calories.m'
%
%   % Example 3: Replace text in a cell array with values in a second cell
%   % array.
%
%       missing_info = {'Start: __'; ...
%                       'End: __'};
%       dates = {'01/01/2001'; ...
%               '12/12/2002'};
%       complete = strrep(missing_info, '__', dates)
%
%       complete = 
%           'Start: 01/01/2001'
%           'End: 12/12/2002'
%    
%   See also STRFIND, REGEXPREP.

%   M version contributor: Rick Spada  11-23-92
%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.17.4.4 $  $Date: 2010/02/25 08:12:46 $
%   Built-in function.
