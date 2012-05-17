function string = iptnum2ordinal(number)
%IPTNUM2ORDINAL Convert positive integer to ordinal string.
%   STRING  =  IPTNUM2ORDINAL(NUMBER)  converts the positive integer NUMBER
%   into the ordinal text string STRING.   
%
%   Examples
%   --------
%       % Convert the number 4 into the text string 'fourth'.
%       ordstring = iptnum2ordinal(4);
%
%       % Convert the number 23 into the text string '23rd'.
%       ordstring2 = iptnum2ordinal(23);
  
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/11/19 17:36:51 $  

if number <= 20
  table1 = {'first' 'second' 'third' 'fourth' 'fifth' 'sixth' 'seventh' ...
            'eighth' 'ninth' 'tenth' 'eleventh' 'twelfth' 'thirteenth' ...
            'fourteenth' 'fifteenth' 'sixteenth' 'seventeenth' ...
            'eighteenth' 'nineteenth' 'twentieth'};
  
  string = table1{number};
  
else
  table2 = {'th' 'st' 'nd' 'rd' 'th' 'th' 'th' 'th' 'th' 'th'};
  ones_digit = rem(number, 10);
  string = sprintf('%d%s',number,table2{ones_digit + 1});
end
