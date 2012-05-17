function schema
%SCHEMA Define the FILEFRAME class.

%	Copyright 2005 The MathWorks, Inc.
%	$Revision: 1.1.6.1 $  $Date: 2005/11/15 01:09:06 $

    pkg = findpackage('hdftool');
    cls = schema.class(pkg,'fileframe');

    prop(1) = schema.prop(cls,'figureHandle', 'MATLAB array');
    prop(2) = schema.prop(cls,'metadataDisplay', 'MATLAB array');
    prop(3) = schema.prop(cls,'metadataScroll', 'MATLAB array');
    prop(4) = schema.prop(cls,'upperRightPanel', 'MATLAB array');
    prop(5) = schema.prop(cls,'lowerRightPanel', 'MATLAB array');
    prop(6) = schema.prop(cls,'figSplitPane', 'MATLAB array');
    prop(7) = schema.prop(cls,'rightSplitPane', 'MATLAB array');
    prop(8) = schema.prop(cls,'currentPanel', 'MATLAB array');
    prop(9) = schema.prop(cls,'noDataPanel', 'MATLAB array');
    prop(10) = schema.prop(cls,'prefs', 'MATLAB array');
    prop(11) = schema.prop(cls,'treeHandle', 'MATLAB array');
    prop(12) = schema.prop(cls,'importMenu', 'MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on');

end
