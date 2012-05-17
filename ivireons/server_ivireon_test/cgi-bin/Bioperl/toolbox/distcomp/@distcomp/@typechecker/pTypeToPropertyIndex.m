function index = pTypeToPropertyIndex(obj, datatype)
; %#ok Undocumented
%Maps a datatype to an index into obj.PropertyInfo.

index = find(strcmp({obj.PropertyInfo.Type}, datatype));
if isempty(index)
    error('distcmomp:typechecker:InvalidDataType', ...
          'No record found for the data type ''%s''.', ...
          datatype);
end    
if length(index) > 1
    error('distcmomp:typechecker:InvalidDataType', ...
          'Found multiple matches to the data type ''%s''.', ...
          datatype);
end
