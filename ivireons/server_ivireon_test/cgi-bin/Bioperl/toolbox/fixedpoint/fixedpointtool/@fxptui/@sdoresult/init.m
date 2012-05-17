function h = init(h,blk,ds) %#ok
%INIT initializes the sdo result class.
    
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:28 $    

h.daobject = blk;
h.figures = java.util.HashMap;
h.actualSrcBlk = {};
h.listeners = handle.listener(h, findprop(h, 'ProposedDT'), 'PropertyPostSet', @(s,e)setProposedDT(h));
