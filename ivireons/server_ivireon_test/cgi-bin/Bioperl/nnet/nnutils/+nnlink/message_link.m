function str = message_link(message,filename)
%NN_WARNING_LINK Message string with link to warning doc file.
%
%  STR = NN_MESSAGE_LINK(message,warning_filename)

% Copyright 2010 The MathWorks, Inc.

str = nnlink.str2link(message,['matlab:doc ' filename]);
