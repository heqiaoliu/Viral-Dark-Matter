function str = slname2html(this,str) 
% SLNAME2HTML  Convert a Simulink path to a string that can be directly
% displayed in html
 
% Author(s): John W. Glass 26-Feb-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/03/13 17:38:44 $

str = regexprep(str,'\n',' ');
str = regexprep(str,'<','&lt;');
str = regexprep(str,'>','&gt;');