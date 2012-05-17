function h = init(h, blk, ds)
%INIT

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 21:34:02 $

h.daobject = blk;
h.figures = java.util.HashMap;
%mdl reference mask name changes
h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)locpropertychange(h,s,e));
%model reference name changes
h.listeners(end+1) = handle.listener(h.mdlref, 'NameChangeEvent', @(s,e)locpropertychange(h,s,e));
h.listeners(end+1) = handle.listener(h.daobject, 'DeleteEvent', @(s,e)destroy(h,ds));
h.listeners(end+1) = handle.listener(h.mdlref, 'DeleteEvent', @(s,e)destroy(h,ds));
h.listeners(end+1) = handle.listener(h, findprop(h, 'ProposedDT'), 'PropertyPostSet', @(s,e)setProposedDT(h));

h.addmodelcloselistener(ds);

%--------------------------------------------------------------------------
function locpropertychange(h,s,e)
if(isa(s, 'Simulink.ModelReference'))
  blkpath = h.getFullName;
  mdlname = s.ModelName;
  blkname = strrep(blkpath, mdlname, '');
  h.FxptFullName = [s.getFullName blkname];
else
  %get the start index of the model ref name
  idx1 = strfind(h.Name, [h.mdlref.Name '/']);
  %get the end index of the model ref name (where block path begins)
  idx2 = idx1 + numel(h.mdlref.Name) + 1;
  if(isempty(idx2)); idx2 = 1; end
  oldname = h.Name(idx2:end);
  newname = s.Name;
  h.Name = strrep(h.Name, oldname, newname);
  if(isempty(h.PathItem))
    h.FxptFullName = [h.mdlref.getFullName '/' s.Name] ;
  else
    h.FxptFullName = [h.mdlref.getFullName '/' s.Name ' : ' h.PathItem] ;
  end
end
h.firepropertychange;
h.updatefigures;

% [EOF]
