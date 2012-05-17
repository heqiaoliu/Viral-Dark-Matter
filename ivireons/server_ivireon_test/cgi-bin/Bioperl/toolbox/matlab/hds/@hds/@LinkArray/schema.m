function schema
% Defines properties for @LinkArray class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/12/22 18:14:02 $

% Register class 
c = schema.class(findpackage('hds'),'LinkArray');

% Public properties
schema.prop(c,'Alias','handle');         % Associated variable (@variable)
schema.prop(c,'Parent','handle');        % Parent data set

% Cell array of data set handles
p = schema.prop(c,'Links','MATLAB array');   
p.AccessFlags.AbortSet = 'off';   % perf optimization

% All data-holding variables accessible through the link
schema.prop(c,'LinkedVariables','handle vector');   

% Top-level variables (data+link) in linked data sets
% RE: Required to be the same for all linked data sets
schema.prop(c,'SharedVariables','handle vector');   

% When Transparency='on', GETSAMPLE follows links
p = schema.prop(c,'Transparency','on/off');  
p.setFunction = @localCheckTransparency;

%------------------------------------------

function v = localCheckTransparency(this,v)
% Check that turning on transparency does not create repeated variables
SharedVars = this.SharedVariables;
if strcmp(v,'on') && ~isempty(SharedVars)
   % Collect visible variables (excluding variables for this LinkArray)
   VisVars = utGetVisibleVars(this.Parent);
   % Check for clashes
   iv = utIntersect(SharedVars,VisVars);
   if ~isempty(iv)
      warning('Variable "%s" appears multiple times when "%s" is made transparent.\nResetting transparency to ''off''.',...
         SharedVars(iv(1)).Name,this.Alias.Name)
      v = 'off';
   end
end

