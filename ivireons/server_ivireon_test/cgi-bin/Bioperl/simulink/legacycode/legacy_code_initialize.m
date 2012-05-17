function varargout = legacy_code_initialize(varargin)
%LEGACY_CODE_INITIALIZE Initializes and validates structure used to define
%   the interface to the legacy code.
%
%   LEGACY_CODE_INITIALIZE() returns an empty structure.
%
%   LEGACY_CODE_INITIALIZE(INSTRUCT) verifies the input structure initalized
%   by calling LEGACY_CODE_INITIALIZE(), and adds missing fields if exist.
%
%   See also LEGACY_CODE_SFCN_CMEX_GENERATE, LEGACY_CODE_COMPILE,
%   LEGACY_CODE_SFCN_TLC_GENERATE and LEGACY_CODE_RTWMAKECFG_GENERATE.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.2 $
%   $Date: 2007/11/17 23:33:25 $

%[varargout{1:nargout}] = slprivate('lct_initialize', varargin{:});
[varargout{1:nargout}] = legacy_code('initialize', varargin{:});