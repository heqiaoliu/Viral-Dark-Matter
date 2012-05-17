function obj = saveobj(obj)
; %#ok Undocumented
%saveobj
%
%  obj = saveobj(obj)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/05/14 15:07:16 $ 

% Define a warning message and ID
warnID = 'distcomp:object:UnableToSave';
% See if it is on - we do this to avoid a stack trace that includes the 
% line in proxyobject.saveobj which looks ugly
query = warning('query', warnID);
WARNING_IS_ON = strcmp(query.state, 'on');
% proxyobjects are intrinsically unserializable so warn and actually save a string
str = sprintf('Warning: object of class %s can not be saved', class(obj)); 
if WARNING_IS_ON
    % Display the warning without the dbstack
    disp(str);
end
% Set lastwarn so that it shows up
lastwarn(str, warnID);
% And save a string otherwise loading will throw an assertion
obj = 'unserializable';