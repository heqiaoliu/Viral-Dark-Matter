function copy_object_properties(hSrc, hDst)
%COPY_OBJECT_PROPERTIES  Takes two UDD object, copies the value of
%each property in source object to value of corresponding (same named)
%property in destination object.  If a property is of UDD handle type,
%recursively copy its contents as well.
%
% Input parameters:
%   1) source UDD object
%   2) destination UDD object

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2008/12/01 07:51:11 $


if isempty(hSrc) || isempty(hDst) || isequal(hSrc, hDst)
  return;
end

isStrictCopy = false;
  % This could be an arg if someone think it's useful. In strict copy mode,
  % two UDD object must be of same or derived class, and any name-matching
  % properties must be of same data type.. etc. In non-strict copy mode,
  % these are not required (instead, will try copying any name-matching
  % properties at best-effort).

hSrcClass = hSrc.classhandle;
hDstClass = hDst.classhandle;

% If strict copy, hDstClass must same as or derived from hSrcClass

if ~hDstClass.isDerivedFrom(hSrcClass) && isStrictCopy
  % NOTE: isDerivedFrom will also true if two classes are same
  DAStudio.error('Simulink:utility:invSrcDestUDDClassType');
end

% Walk through each property of hSrc, 
% if it's not a UDD handle, set the value to same-named hDst property.
% otherwise recursively copy the properties of that UDD handle

hSrcProps = hSrcClass.Properties;
hDstProps = hDstClass.Properties;

for p = 1 : length(hSrcProps)
  pName = hSrcProps(p).Name;
  spType = hSrcProps(p).DataType;

  % Skip if this hSrc property does not allow public get

  spFlags = hSrcProps(p).AccessFlags(1);
  if (strcmp(spFlags.PublicGet, 'off') || ...
      strcmp(spFlags.Copy,      'off'))
    continue;  % go to next property
  end
  try
    spVal = get(hSrc, pName);
  catch err
    if isStrictCopy
      rethrow(err);%#ok
    else       
      continue;
    end
  end

  % Find the same-named property in hDst

  dp = find(hDstProps, 'Name', pName);
  if isempty(dp)
    if isStrictCopy
      DAStudio.message('Simulink:dialog:CannotFindPropInDestObj', pName);%#ok
    else
      continue;  % go to next property
    end
  end
  dpType = dp.DataType;

  % Are source and destination properties same type?

  if ~strcmp(spType, dpType) && isStrictCopy
    DAStudio.error('Simulink:utility:invSrcDestClassType', pName);
  end

  % If the source property is not handle, copy its value

  if ~strcmp(spType, 'handle')
    try
      set(hDst, pName, spVal);
    catch err
      if isStrictCopy
        rethrow(err);%#ok
      else
        continue;
      end
    end

  % Else, see if the destination property is also handle

  else
    if ~strcmp(dpType, 'handle')
      % Could assert(~isStrictCopy) here.
      continue;  % go to next property
    end

    % Get the destination handle

    dpFlags = dp.AccessFlags(1);
    if strcmp(dpFlags.PublicGet, 'off')
      if isStrictCopy
        DAStudio.error('Simulink:dialog:DestObjDoesNotAllowPublicGet', pName);%#ok
      else
        continue;
      end
    end
    try
      dpVal = get(hDst, pName);
    catch err
      if isStrictCopy
        rethrow(err);%#ok
      else
        continue;
      end
    end

    % Then copy recursively

    copy_object_properties(spVal, dpVal);  % could pass isStrictCopy if it's arg
  end

end  % of for length hSrcProps

% end copy_object_properties()


% EOF
