function legacy_code_rtwmakecfg_generate(varargin)
%LEGACY_CODE_RTWMAKECFG_GENERATE Generates the file "rtwmakecfg.m" that adds
%   include and source directories to RTW make files.
%
%   LEGACY_CODE_COMPILE(INSTRUCT) Generates the file "rtwmakecfg.m" common
%   to all SFunctions described in the INSTRUCT array of structures.
%
%   See also LEGACY_CODE_INITIALIZE, LEGACY_CODE_SFCN_CMEX_GENERATE,
%   LEGACY_CODE_SFCN_TLC_GENERATE and LEGACY_CODE_COMPILE.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.2 $
%   $Date: 2007/11/17 23:33:27 $

% slprivate('lct_gen_rtwmakecfg', varargin{:});
legacy_code('rtwmakecfg_generate', varargin{:});