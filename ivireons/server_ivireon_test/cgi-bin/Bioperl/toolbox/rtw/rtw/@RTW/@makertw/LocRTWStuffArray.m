function output = LocRTWStuffArray(h, varargin)
% LocRTWStuffArray - Copies the field values of one array to another array.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/06/20 20:19:18 $

% The description of the original RTWStuffArray is:
%
%    RTWStuffArray(array1, array2, {primary_key, secondary_key}, ...
%                  {field1, field1a}, {field2, field2a}, ...)
%
% results in the following:
%
% All cases where array1(i).primary_key == array2(j).secondary_key,
%   array1(i).field1 <-- array2(j).field1a
%   array1(i).field2 <-- array2(j).field2a
%                     .
%                     .
%                     .
% Example:
%  arr1(1).a = 'a';
%  arr1(1).b = 'b';
%  arr1(1).c = 'c';
%  arr1(2).a = 'a2';
%  arr1(2).b = 'b2';
%  arr1(2).c = 'c2';
%
%  arr2(1).d = 'a2';
%  arr2(1).e = 'e';
%  arr2(1).f = 'f';
%  arr2(2).d = 'a';
%  arr2(2).e = 'e2';
%  arr2(2).f = 'f2';
%  RTWStuffArray(arr1, arr2, {'a', 'd'}, {'b', 'e'})
%    would result in
%  arr1(1).a,b,c = {'a', 'e2', 'c'}
%  arr1(2).a,b,c = {'a2', 'e', 'c2'}
%
% This function extends RTWStuffArray in the following way:
% LocRTWStuffArray(array1, array2, {primary_key, secondary_key}, ...
%                  {field1, field1a, mapfcn1}, {field2, field2a, mapfcn2}, ...)
% results in the following:
% All cases where array1(i).primary_key == array2(j).secondary_key,
%   array1(i).field1 <-- mapfcn1(array1(i), array2(j), array2(j).field1a)
%   array1(i).field2 <-- mapfcn2(array1(i), array2(j), array2(j).field2a)

if (nargin-1) < 4
    DAStudio.error('RTW:makertw:invalidstuffArrayUsage');
end

array1 = varargin{1};
array2 = varargin{2};

% Not sure about the following behavior for empty arrays. May need to
% change it.
if (isempty(array1))
  output = array1;
  return;
elseif (isempty(array2))
  output = array2;
  return;
end

if (~(isstruct(array1) && isstruct(array2)))
    DAStudio.error('RTW:makertw:structArrayRequired');
end

keyPair = varargin{3};
if (~(iscell(keyPair) && (length(keyPair) == 2)))
    DAStudio.error('RTW:makertw:invalidKeyField');
end

primaryKey = keyPair{1};
secondaryKey = keyPair{2};

if (~isfield(array1, char(primaryKey)))
    DAStudio.error('RTW:makertw:invalidKey',primaryKey,'primary');
elseif (~isfield(array2, char(secondaryKey)))
    DAStudio.error('RTW:makertw:invalidKey',secondaryKey,'secondary');
end

% Do some more error checking.
for k = 4:length(varargin)
  fieldPair = varargin{k};
  if (isequal(fieldPair{1}, primaryKey))
      DAStudio.error('RTW:makertw:duplicateKey',fieldPair{1},primaryKey);
  elseif (isequal(fieldPair{2}, secondaryKey))
      DAStudio.error('RTW:makertw:duplicateKey',fieldPair{2},secondaryKey);
  end
end

for k = 1:length(array1)
  key1val = getfield(array1(k), primaryKey);
  for l = 1:length(array2)
    key2val = getfield(array2(l), secondaryKey);

    if ~(isequal(key1val, key2val)) continue; end

    for j = 4:length(varargin)
      fieldPair = varargin{j};
      field1 = fieldPair{1};
      field2 = fieldPair{2};

      if ( ~isfield(array1(k), field1) | ~isfield(array2(l), field2) )
        continue;
      end

      mapFcn = fieldPair{3};

      value2 = getfield(array2(l), field2);
      if isempty(mapFcn),
        value1 = value2;
      else
        value1 = feval(mapFcn, array1(k), array2(l), char(value2));
      end
      array1(k) = setfield(array1(k), field1, value1);
    end
    array2(l) = '';
    break;
  end
end
output = array1;

%endfunction LocRTWStuffArray

% Function: LocMapFcn ==========================================================
%
function output = LocMapFcn(record1, record2, value)
% LocMapFcn - Maps the value of a record of type rtwoption to its
% equivalent for an optionarray.  See beginning of this file for
% descriptions of "rtwoption" and "optionarray".

  if (isfield(record1,'type') & ~isempty(record1.type))
    switch(record1.type)
     case 'Popup'
      % Strip all quotation marks from the value fields (presumably inserted
      % for a popup)
      output = strrep(value, '"', '');
      return;
     case 'Checkbox'
      if (isequal(value,'1'))
	output = 'on';
      else
	output = 'off';
      end
     otherwise
      output = value;
    end
  else
    output = value;
  end

%endfunction LocMapFcn
