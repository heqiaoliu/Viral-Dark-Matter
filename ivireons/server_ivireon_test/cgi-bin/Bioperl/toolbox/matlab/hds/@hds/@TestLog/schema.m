function schema
% Defines properties for @TestLog class (file-based storage 
% of data associated with single test)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:18 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'TestLog',findclass(p,'dataset'));

% Public properties
p = schema.prop(c,'Storage','handle');  % Array container 
p.SetFunction = @LocalUpdateStorage;


%--------------- Local Functions -----------------------

function Value = LocalUpdateStorage(this,Value)
if ~isa(Value,'hds.ArrayContainer')
   error('Invalid value for Storage property.')
end
this.utSetStorage(Value);
