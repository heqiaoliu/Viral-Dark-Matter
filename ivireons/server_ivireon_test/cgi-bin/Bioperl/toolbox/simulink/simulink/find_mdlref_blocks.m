function [mdlrefs,liblinks,blockcount] = find_mdlref_blocks(mdlname)
%Private function used by Simulink.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  

%FIND_MDLREF_BLOCKS Find model references and library links
%   [mdlrefblocks,librarylinkblocks] = FIND_MDLREF_BLOCKS('MDLNAME')

[mdlrefs,liblinks,blockcount] = slInternal('findMdlRefsAndLibLinks',mdlname);

