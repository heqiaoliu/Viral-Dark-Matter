function [summaryMsg,defaultMsg,delimiter,detailedMsg,detailsTable] = optimExitMsgParts(exitMsg)
%OPTIMEXITMSGPARTS split exit messages from Optimization Toolbox solvers.
%
% This utility splits the combined exit messages (default and detailed)
% returned by Optimization Toolbox solvers in the output structure
% "message" field. 
%
% The input message is split into and returned in 5 separate parts (if all
% 5 parts exist in the input message):
% 
% - The summary sentence (e.g. "Local minimum found.")
% - The default message body (e.g. "fmincon stopped because...")
% - The message delimiter (e.g. "Stopping criteria details: ")
% - The detailed message body (e.g. "Optimization completed: ...")
% - The detailed message table (e.g. "first-order optimality = XXXe-XX")
% 
% Otherwise, the missing parts are returned as empty strings ('').

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/29 08:31:56 $

% Set the default values to empty.
msgComponents = {'','','','',''};

% Split the message into components based on a line-break ('\n\n').
% Also, trim leading and trailing spaces and newline characters with strtrim.
temp = strtrim(regexp(exitMsg,'\n\n','split'));

% Copy components into cell array that is already populated with default
% values ('').
[msgComponents{1:length(temp)}] = temp{:};

% Copy strings from cell array into output variables. 
[summaryMsg,defaultMsg,delimiter,detailedMsg,detailsTable] = msgComponents{:};