function [ConfigID,FeedbackSigns] = getconfig(this)
%GETCONFIG  Returns current loop configuration

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:39:55 $
[ConfigID,FeedbackSigns] = getconfig(this.Plant);
