function A = scribehgobj(HGHandle)
%SCRIBEHGOBJ/SCRIBEHGOBJ Make scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.14.4.3 $  $Date: 2008/08/14 01:37:54 $

if nargin==0
   A.Class = 'scribehgobj';
   A.HGHandle = [];
   A.ObjBin = {};
   A.ObjSelected = [];
   A.SavedState = {};
   A.Draggable = [];
   A.DragConstraint = [];
   A = class(A,'scribehgobj');
   return
end

if isa(HGHandle, 'scribehgobj')
   A = HGHandle;
elseif ishghandle(HGHandle)

   A.Class = 'scribehgobj';   
   A.HGHandle = HGHandle;
   A.ObjBin = {};
   A.ObjSelected = 0;
   A.SavedState = {};
   A.Draggable = 1;
   A.DragConstraint = '';   
   
   A = class(A,'scribehgobj');
else
   error('MATLAB:graph2d:scribehgobj:invalidconstructor','scribehgobj constructor requires an HG handle');
end
