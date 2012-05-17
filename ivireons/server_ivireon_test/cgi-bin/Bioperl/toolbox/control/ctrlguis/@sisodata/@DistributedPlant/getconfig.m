function [ConfigID,FeedbackSigns] = getconfig(this)
%GETCONFIG  Returns current loop configuration

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/20 20:00:36 $
ConfigID = this.Configuration;
FeedbackSigns = this.LoopSign;