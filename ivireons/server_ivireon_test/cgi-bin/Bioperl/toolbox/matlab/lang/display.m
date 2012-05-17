%DISPLAY Display array.
%   DISPLAY(X) is called for the object X when the semicolon is not used
%   to terminate a statement. 
%
%   For example,
%     X = inline('sin(x)')
%   calls DISPLAY(X) while
%     X = inline('sin(x)');
%   does not.
%
%   A typical implementation of DISPLAY calls DISP to do most of the work
%   and looks as follows.  Note that DISP does not display empty arrays.
%
%      function display(X)
%      if isequal(get(0,'FormatSpacing'),'compact')
%         disp([inputname(1) ' =']);
%         disp(X);
%      else
%         disp(' ');
%         disp([inputname(1) ' =']);
%         disp(' ');
%         disp(X);
%      end
%   
%   See also INPUTNAME, DISP, EVALC.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2005/06/27 22:48:56 $
%   Built-in function.
