function result = requestJavaAdapter(object)
%REQUESTJAVAADAPTER Support function for GUIDE

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $
 
%%%%%%%  CAUTION                                           %%%%%%%%
%%%%%%%  This file is duplicated in both uitools and guide %%%%%%%%%
%%%%%%%  %TODO - determine if this functionality can be    %%%%%%%%%
%%%%%%%  broken out or replaced so this file doesn't exist %%%%%%%%%
%%%%%%%  in two places                                     %%%%%%%%%
 
  len = length(object);
  if len == 1
    if (ishghandle(object) || isa(object, 'handle') || ishandle(object)) && ~isjava(object)
      %if not MCOS object cast it to handle, otherwise pass it directly to
      %java()
      if ~isobject(object)
          result = java(handle(object));
      else
          if ~isa(object, 'JavaVisible')
              error('MATLAB:requestJavaAdapter:invalidobject', 'This object cannot be inspected because its class is not a subclass of JavaVisible.');
          end
          
          result=java(object);
      end
    else
      error('MATLAB:requestJavaAdapter:InvalidInput', '''requestJavaAdapter'' argument must be a handle list.');
    end
  else
    if ~isempty(object) && (all(ishghandle(object)) || all(isa(object, 'handle') || all(ishandle(object))) && ~isjava(object))
        result = cell(len, 1);
        if all(isobject(object))
            for i = 1:len
                result{i}=java(object(i));
            end
        else
            for i = 1:len
                result{i} = java(handle(object(i)));
            end
        end
    else
        error('MATLAB:requestJavaAdapter:InvalidArgument', '''requestJavaAdapter'' argument must be a handle list.');
    end
  end
