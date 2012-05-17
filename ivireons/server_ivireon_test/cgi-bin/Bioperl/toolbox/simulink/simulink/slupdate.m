function report = slupdate(varargin)
%SLUPDATE Replace blocks from a previous release with newer ones
%
%   SLUPDATE(SYS) replaces obsolete versions of blocks within model
%   SYS to be compatible with the current version of Simulink.
%   
%   Note:  the model must be open prior to calling SLUPDATE.  
%
%   SLUPDATE(SYS, PROMPT) will prompt the user for each instance of 
%   a replaceable block if the value of PROMPT is 1. This is the
%   default. A value of 0 will not prompt the user.
%
%   When prompted, the user has three options.
%   - "y" : Replace the block  (default)
%   - "n" : Do not replace the block
%   - "a" : Replace all blocks without further prompting
%
%   In addition to updating obsolete blocks, SLUPDATE also performs
%   these operations:
%
%   1) Reconnect broken links to MathWorks library masked blocks so 
%      that changes made by MathWorks under the mask will be updated 
%      in the model. If you have customized the contents of these
%      masks and they are not library links, this operation will
%      overwrite those changes.
%
%   2) Update obsolete configuration settings for SYS
%
%   SLUPDATE(SYS,'OperatingMode','Analyze') will only perform the 
%   analysis portion and not change anything in the model.  It 
%   analyzes referenced models, linked libraries, and S-functions
%   and then returns a data structure with the following fields:
%
%          Message: string containing a summary message of the results
%        blockList: cell array of blocks that need updating
%     blockReasons: cell array of reason for updating corresponding block
%        modelList: cell array of referenced models and top model
%      libraryList: cell array of non-MathWorks libraries referenced
%         sfunList: cell array of S-functions referenced
%           sfunOK: logical array S-function status: false=update, true=OK
%         sfunType: cell array of apparent S-function category: m, mex
%
%   See also FIND_SYSTEM, GET_PARAM, ADD_BLOCK, MODELADVISOR

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.81.4.25 $ $Date: 2008/12/01 07:51:46 $

    obj = ModelUpdater(varargin{:});
    
    updateModelForProducts(obj);

    restoreBrokenLinks(obj);
    
    report = generateReport(obj);
    
    cleanup(obj);
       
end
