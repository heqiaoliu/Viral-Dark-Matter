function throw(tag,message,varargin)
%NNERR Throws nnet error in calling function, with update message.
%
%  NNERR(TAG,MESSAGE) throws the error ('nnet:FILENAME:TYPE',message)
%  in the calling function, where FILENAME is the name of the calling
%  function.
%
%  NNERR(TYPE,MESSAGE,NAME) updates message by replacing an occurance
%  of 'VALUE' with the string NAME before throwing the error.
%
%  NNERR(TYPE,MESSAGE,NAME1,NAME2,...) updates message by replacing
%  occurances of 'VALUE1', 'VALUE2', etc., with strings NAME1, NAME2, etc.
%
%  NNERR(TYPE,MESSAGE,{NAME1,NAME2,...}) is an alternate calling
%  form to NERR(TYPE,MESSAGE,NAME,NAME2,...)

% Copyright 2010 The MathWorks, Inc.

if nargin == 1
  message = tag;
  tag = 'Arguments';
end

% Alternate calling forms
names = varargin;
if (length(names)==1) && iscell(names{1})
  names = names{1};  
end

% Fill in value names in message
if isempty(names)
  message = nnerr.value(message,'Value');
else
  message = nnerr.value(message,names);
end

% Thow error in calling function
throwAsCaller(MException(nnerr.tag(tag,2),message));
