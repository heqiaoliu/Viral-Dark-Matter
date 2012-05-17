function legacy_code_sfcn_tlc_generate(varargin)
%LEGACY_CODE_SFCN_TLC_GENERATE Generates the TLC interface for calling
%   Legacy Code.
%
%   LEGACY_CODE_SFCN_TLC_GENERATE(INSTRUCT) generates the TLC file
%   associated to the SFunction described in structure INSTRUCT
%  (can be an array of structures).
%
%   See also LEGACY_CODE_INITIALIZE, LEGACY_CODE_SFCN_CMEX_GENERATE,
%   LEGACY_CODE_COMPILE and LEGACY_CODE_RTWMAKECFG_GENERATE.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.3 $
%   $Date: 2008/08/08 13:05:34 $

% slprivate('lct_gen_sfcn_tlc', varargin{:});
legacy_code('sfcn_tlc_generate', varargin{:});
