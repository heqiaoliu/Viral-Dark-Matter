function varargout = dfswitchyard(action,varargin)
% DFSWITCHYARD switchyard for Distribution Fitting.
% Helper function for the Distribution Fitting tool

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:13:21 $

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end

% The following lines list functions that are called via this
% function from other Statistics Toolbox functions.  These lines
% insure that the compiler will include the functions listed.
%#function mgrp2idx
%#function dfgetdistributions
%#function dfhistbins
%#function dfhelpviewer
%#function dfupdatexlim
%#function dfupdateylim
%#function getdsdb
%#function statremovenan
%#function statinsertnan
%#function statgetkeyword
%#function statkscompute
%#function statparamci
%#function statParallelStore
