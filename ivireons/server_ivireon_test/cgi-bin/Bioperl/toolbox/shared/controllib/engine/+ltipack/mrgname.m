function [Names1,clash] = mrgname(Names1,Names2)
%MRGNAME  Input/output name management.  
%
%   [NAMES,CLASH] = MRGNAME(NAMES1,NAMES2)  merges the two
%   sets of I/O names NAMES1 and NAMES2.  Empty entries of 
%   NAMES1 are overwritten by corresponding entries of NAMES2,
%   and the remaining entries are left untouched.
%
%   If both nonempty, NAMES1 and NAMES2 are assumed of the 
%   same length.

%   Author(s): P. Gahinet, 4-1-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:57 $
clash = false;
if ~isempty(Names2)
   if isempty(Names1)
      Names1 = Names2;
   else
      % Build merged name list
      % RE: in case of name clash, NAMES1 should be left untouched
      EmptyNames1 = strcmp(Names1,'');
      EmptyNames2 = strcmp(Names2,'');      
      % Check for clashes among specified names
      idx = find(~EmptyNames1 & ~EmptyNames2);
      if ~isequal(Names1(idx),Names2(idx))
         clash = true;
      end
      % Replace undefined names in NAMES1 by corresponding names in NAMES2
      Names1(EmptyNames1,:) = Names2(EmptyNames1,:);
   end
end
