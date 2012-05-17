function schema
% SCHEMA Defines class properties
%
%   Authors: James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:58:13 $

% Target type
% if isempty(findtype('IOTarget'))
%     schema.EnumType('IOTarget', {'input','output','state'});
% end

% Get handles of associated packages and classes
hCreateInPackage = findpackage('tsguis');
hSupClass = findclass(findpackage('sharedlsimgui'), 'abstractimporttable');

% Construct class
c = schema.class(hCreateInPackage, 'iotable',hSupClass);

% ---------------------------------------------------------------------------- %
% Define class properties
% ---------------------------------------------------------------------------- %
% Handle of the node corresponding to the importer target table
p = schema.prop( c, 'Explorer', ....
    'com.mathworks.toolbox.control.explorer.Explorer' );
set( p, 'AccessFlags.PublicSet', 'off', ...
        'AccessFlags.Serialize', 'off' );
p = schema.prop( c, 'ImportSelector', 'handle' );
set( p, 'AccessFlags.PublicSet', 'off', ...
        'AccessFlags.Serialize', 'off' );
    
