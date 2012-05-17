function schema
% Defines properties for @steprespdata a specialized @piecewisedata class

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:05 $

pk = findpackage('srorequirement');

% Register class 
c = schema.class(pk,'steprespdata',findclass(pk,'piecewisedata'));

%Native property
schema.prop(c,'Requirement','handle');  %Parent response containing the data
                                        %Needed for step access to
                                        %characteristics


