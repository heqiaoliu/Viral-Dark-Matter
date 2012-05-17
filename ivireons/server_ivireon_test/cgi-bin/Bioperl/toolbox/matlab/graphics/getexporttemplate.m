function pt = getexporttemplate( h )
%GETEXPORTTEMPLATE Get a figure's ExportTemplate

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2006/05/27 18:09:06 $

pt = get(h, 'ExportTemplate');
if isempty(pt)
    initprintexporttemplate(h);
    pt = get(h, 'ExportTemplate');
end

