function [tmf,envVal,mexOpts] = raccel_default_tmf
%CSIM_DEFAULT_TMF Returns the "default" template makefile for use with csim.tlc
%
%       See get_tmf_for_target in the toolbox/rtw/private directory for more 
%       information.

%       Copyright 2007-2010 The MathWorks, Inc.
%       $Revision: 1.1.6.1.14.1 $

[tmf,envVal,mexOpts] = get_tmf_for_target('raccel');

%end csim_default_tmf.m

% LocalWords:  CSIM csim
