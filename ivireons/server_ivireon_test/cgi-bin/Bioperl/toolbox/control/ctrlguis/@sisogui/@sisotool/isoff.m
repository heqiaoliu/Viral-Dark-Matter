function boo = isoff(sisodb)
%ISOFF  Returns 1 (true) if editors are off (no data loaded).

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2008/10/31 05:55:49 $

if isempty(sisodb.PlotEditors)
    % Protect against when editors have not been created.
    boo = true;
else
    boo = strcmp(sisodb.PlotEditors(1).EditMode,'off');
end