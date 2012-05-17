function h = messenger
% Returns singleton instance of @messenger class.
% Do not call this constructor directly. Instead, use the package method
% getMessengerInstance.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/10/02 18:50:52 $

%{
mlock
persistent thismessenger;

if isempty(thismessenger) || ~ishandle(thismessenger)
    thismessenger = nlutilspack.messenger;
end

h =  thismessenger;
%}

h = nlutilspack.messenger;
h.MessengerID = 'OldSITBGUI';  %existing GUI "task" name
