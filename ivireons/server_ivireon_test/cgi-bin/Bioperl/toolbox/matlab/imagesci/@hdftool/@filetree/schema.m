function schema
%SCHEMA Define the FILETREE class.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:09:14 $

    pkg = findpackage('hdftool');
    cls = schema.class(pkg,'filetree');

    prop(1) = schema.prop(cls,'treeHandle', 'MATLAB array');
    prop(2) = schema.prop(cls,'fileFrame', 'MATLAB array');
    prop(3) = schema.prop(cls,'filename', 'MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
             'AccessFlags.PrivateSet','on',...
             'AccessFlags.PublicGet','on',...
             'AccessFlags.PublicSet','on'); 

end
