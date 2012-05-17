function info(arg)
%INFO   Information about MathWorks.
%   INFO displays information about MathWorks in the Command Window.
%
%   See also WHATSNEW.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/03/31 18:24:09 $

disp(' ')
disp('For information about MathWorks, go to:')
if feature('hotlinks')
    disp('<a href="matlab:web(''http://www.mathworks.com/company/aboutus/contact_us'',''-browser'')">http://www.mathworks.com/company/aboutus/contact_us</a>')
else
    disp('http://www.mathworks.com/company/aboutus/contact_us')
end
disp('or call +1 508 647 7000.')
disp(' ')
