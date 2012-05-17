function strOut = matchKey(str,StrList)
% Matches input string against list of possible values.
%
%   STR = MATCHKEY(STR,STRLIST) looks for a string in STRLIST that matches
%   the input string STR. The output is either '' (no match or multiple
%   hits) or ones of the strings in STRLIST.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:41 $
strOut = '';
if ischar(str)
   idx = find(strncmpi(str,StrList,max(1,length(str))));
   nhit = length(idx);
   if nhit==1
      strOut = StrList{idx};
   elseif nhit>1
      % Look for exact match, e.g., p vs {'p','pi','pid'}
      idxe = find(strcmpi(str,StrList(idx)));
      if length(idxe)==1
         strOut = StrList{idx(idxe)};
      end
   end
end