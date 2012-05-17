function createtoolbar(h)
%CREATETOOLBAR   

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:57:20 $

% tb = createtoolbar_file(h);
% tb.addSeparator;


tb = createtoolbar_scale(h);
tb.addSeparator;

tb = createtoolbar_data(h, tb);
tb.addSeparator;

tb = createtoolbar_run(h, tb);
tb.addSeparator;

tb = createtoolbar_view(h, tb);
tb.addSeparator;

createtoolbar_search(h);




% [EOF]
