function this = filetree(fileFrame, treeHandle, filename)
%FILETREE Construct a FILETREE object.
%   The filetree is responsible for opening files as well as 
%   creating nodes and a UITREE in which to contain them.
%
%   Function arguments
%   ------------------
%   FILEFRAME: the FILEFRAME object which contains us.
%   TREEHANDLE: the handle to the tree in which we insert nodes.
%   FILENAME: the name of the file that corresponds to the tree.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:09:13 $

    this = hdftool.filetree;
    this.fileFrame  = fileFrame;
    this.treeHandle = treeHandle;
    this.filename   = filename;
    
end
