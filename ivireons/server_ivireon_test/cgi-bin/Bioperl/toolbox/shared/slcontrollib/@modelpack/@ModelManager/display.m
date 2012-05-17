function display(this)
% DISPLAY Show object properties in a formatted form

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/07/14 17:12:05 $

fprintf( 'Managed Models:\n' );
if ~isempty(this.Models)
   models = [this.Models.hModel];
   refs   = [this.Models.refCount];
   for ct = 1:length(models)
      fprintf( '   (%d) %s (%s) with %d reference(s)\n', ct, models(ct).getName, class(models(ct)), refs(ct) );
   end
end
end
