function B = saveobj(obj)
%SAVEOBJ Save filter for objects.
%
%    B = SAVEOBJ(A) is called by SAVE when an object is saved to a .MAT
%    file. The return value B is subsequently used by SAVE to populate the
%    .MAT file.  SAVEOBJ can be used to convert an object that maintains 
%    information outside the object array into saveable form (so that a
%    subsequent LOADOBJ call can recreate it).
%
%    SAVEOBJ will be separately invoked for each object to be saved.
%
%    SAVEOBJ can be overloaded only for user objects.  SAVE will not call
%    SAVEOBJ for a built-in datatype (such as double) even if @double/saveobj
%    exists.
%
%    See also SAVE, LOADOBJ.
%

%    Copyright 2001-2008 The MathWorks, Inc. 
%    $Revision: 1.2.4.2 $  $Date: 2010/04/21 21:32:24 $
if isvalid(obj)
    B.version = 3;  %Version to be used in 9a and forward.  Version will be 
        % incremented only if loadobj is no longer able to read the new format.
    vals = getSettableValues(obj);
    for i = 1:length(vals)
        B.(vals{i}) = get(obj, vals{i});
    end
elseif isempty(obj)
    B = [];    
end
