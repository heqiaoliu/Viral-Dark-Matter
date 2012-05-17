function [ConfigID,FeedbackSigns] = getconfig(this)
%GETCONFIG  Returns current loop configuration

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2006/06/20 20:01:31 $
ConfigID = this.Configuration;
FeedbackSigns = [];
