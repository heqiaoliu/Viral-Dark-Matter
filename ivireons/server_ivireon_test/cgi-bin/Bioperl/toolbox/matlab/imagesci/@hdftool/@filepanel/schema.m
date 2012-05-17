function schema
%SCHEMA Define the FILEPANEL class.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:09:10 $

    pkg = findpackage('hdftool');
    cls = schema.class(pkg,'filepanel');

    prop(1) = schema.prop(cls,'mainPanel','MATLAB array');
    prop(2) = schema.prop(cls,'fileTree','MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
             'AccessFlags.PrivateSet','on',...
             'AccessFlags.PublicGet','on',...
             'AccessFlags.PublicSet','on');

end
