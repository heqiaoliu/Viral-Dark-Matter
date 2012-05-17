function hEditor = PropEditor(plot,CurrentFlag)
%PROPEDITOR  Returns instance of Property Editor for response plots.
%
%   HEDITOR = PROPEDITOR(PLOT) returns the (unique) instance of  
%   Property Editor for w/r plots, and creates it if necessary.
%
%   HEDITOR = PROPEDITOR(PLOT,'current') returns [] if no Property 
%   Editor exists.

%   Authors: Adam DiVergilio and P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:20:55 $
persistent hPropEdit
if nargin==1 && isempty(hPropEdit) && usejava('MWT')
   % Create and target prop editor if it does not yet exist
   hPropEdit = cstprefs.propeditor({'Labels','Limits','Style'});
end
hEditor = hPropEdit;