function this = setID(this, ID)
% SETID Sets the identifier object associated with THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:34 $

% Type checking
if ~isa(ID, 'modelpack.StateID')
  ctrlMsgUtils.error( 'SLControllib:modelpack:errArgumentType', ...
                      'ID', 'modelpack.StateID' );
end

% Handle vectorized call
for ct = 1:numel(this)
  h  = this(ct);
  id = copy( ID(ct) );

  h.ID = id;
  h.setName( id.getName );
end
