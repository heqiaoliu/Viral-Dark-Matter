function optimabout()
%OPTIMABOUT helper that displays the About Box  

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/29 08:28:54 $

a = ver('optim');
str = sprintf(['Optimization Toolbox %s\n',...
               'Copyright 1990-%s The MathWorks, Inc.'], ...
               a.Version,a.Date(end-3:end));
aboutTitle = sprintf('About Optimization Toolbox');
msgbox(str,aboutTitle,'modal');
