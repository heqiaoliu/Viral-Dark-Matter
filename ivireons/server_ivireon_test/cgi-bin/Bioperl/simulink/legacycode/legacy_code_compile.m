function legacy_code_compile(varargin)
%LEGACY_CODE_COMPILE Compiles the CMEX interface for calling
%   Legacy Code.
%
%   LEGACY_CODE_COMPILE(INSTRUCT) compiles the SFunction described in
%   structure INSTRUCT (can be an array of structures) by invoking the mex
%   script.
%
%   LEGACY_CODE_COMPILE(INSTRUCT, OPT) compiles the SFunction described in
%   structure INSTRUCT (can be an array of structures) by invoking the mex
%   script with option OPT.
%
%   See also LEGACY_CODE_INITIALIZE, LEGACY_CODE_SFCN_CMEX_GENERATE,
%   LEGACY_CODE_SFCN_TLC_GENERATE and LEGACY_CODE_RTWMAKECFG_GENERATE.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.3 $
%   $Date: 2008/08/08 13:05:31 $

% slprivate('lct_compile', varargin{:});
legacy_code('compile', varargin{:});
