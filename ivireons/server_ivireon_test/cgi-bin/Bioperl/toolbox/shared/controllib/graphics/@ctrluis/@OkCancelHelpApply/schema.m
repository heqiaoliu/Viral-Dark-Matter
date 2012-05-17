function schema
% SCHEMA  Defines properties for @OkCancelHelpApply class
%
% Note inheritance from @OkCancelHelp class

% Author(s): Alec Stothert
% Revised:
% Copyright 1986-2004 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:25 $

%Package
pk = findpackage('ctrluis');

%Class
c = schema.class(pk,'OkCancelHelpApply',pk.findclass('OkCancelHelp'));

%Properties
%Handles to the apply button, read only
p = schema.prop(c,'hApply','double');
p.AccessFlags.PublicSet = 'off';

