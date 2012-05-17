function legacy_code_gen_sim(varargin)
%LEGACY_CODE_GEN_SIM Generates the SFunction and other necessary files for
%   for calling Legacy Code in simulation.
%
%   LEGACY_CODE_GEN_SIM(INSTRUCT) generates the SFunction and other necessary
%   files described in structure INSTRUCT (can be an array of structures).
%
%   See also LEGACY_CODE_INITIALIZE

%   Copyright 2005-2008 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.3 $
%   $Date: 2008/08/08 13:05:32 $

% slprivate('lct_gen_sim', varargin{:});
legacy_code('generate_for_sim', varargin{:});
