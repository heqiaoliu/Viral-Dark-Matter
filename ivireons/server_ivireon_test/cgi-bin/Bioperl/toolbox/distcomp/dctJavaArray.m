function jArray = dctJavaArray(mArray, baseType)
; %#ok Undocumented
%DCTJAVAARRAY convert a java object or a cell array to a java array
%
%  JAVAARRAY = DCTJAVAARRAY(MATLABARRAY)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:33:08 $ 


% Test if the input is a cell array
if iscell(mArray)
    if numel(mArray) == 0
        error('distcomp:dctjavaarray:InvalidArgument', 'All dimensions of a java array must be greater than zero');
    end
    if nargin < 2 
        baseType = class(mArray{1});
    end
    % Need to deal with MATLAB vectors differently as java doesn't
    % understand that a n x 1 should actually be a 1-d array
    arraySize = size(mArray);    
    if numel(arraySize) == 2 && arraySize(2) == 1
        arraySize = arraySize(1);       
    end
    % Lets see if we can create the array 
    jArray = javaArray(baseType, arraySize);
    % And now fill it up
    jArray = iFillJavaArray(jArray, mArray);
elseif isjava(mArray)
    if nargin < 2
        baseType = class(mArray);
    end
    jArray = javaArray(baseType, 1);
    jArray(1) = mArray;
else
    error('distcomp:dctjavaarray:InvalidArgument', 'The input to dctJavaArray is either a cell array of java objects or a java object');
end


function jArray = iFillJavaArray(jArray, mArray)
% NOTE - this subfunction only fills rectangular java arrays - and thus
% assumes that the jArray is of the correct size to deal with the mArray
HAS_MORE_DIMS = numel(jArray) > 0 && numel(jArray(1)) > 1;
for i = 1:numel(jArray)
    if HAS_MORE_DIMS
        arrayIndexStr = [i repmat({':'}, [1 ndims(mArray) - 1])];
        reducedMArray = squeeze(subsref(mArray, substruct('()', arrayIndexStr)));
        iFillJavaArray(jArray(i), reducedMArray);
    else
        jArray(i) = mArray{i};
    end
end