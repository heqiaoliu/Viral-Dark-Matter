function reset(this,Scope,C)
% Cleans up dependent data when core data changes.
%
%   RESET(this,'all')
%   RESET(this,'root',C)
%   RESET(this,'gain',C)
%   RESET(this,'ol',C)

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/26 17:22:09 $
% 

tmp = cell(length(this.TunedLFT.IC),1);

if strcmp(Scope ,'all')
    this.ModelData = tmp;
    this.Margins = [];
    this.TunedLFT.SSData = tmp;
    this.TunedLFT.ZPKData = tmp;
    this.TunedLFT.FRDData = tmp;
    this.TunedLFTSSData = tmp;

else
    % Check if TunedLoop depends on C
    isTunedFactor = any(C == this.TunedFactors);
    isTunedLFTBlock = any(C == this.TunedLFT.Blocks);

    if isTunedFactor || isTunedLFTBlock
        this.ModelData = tmp;
        this.Margins = [];
        
        % Only clear TunedLFT cache if necessary
        if isTunedLFTBlock
            this.TunedLFT.SSData = tmp;
            this.TunedLFT.ZPKData = tmp;
            this.TunedLFT.FRDData = tmp;
            this.TunedLFTSSData = tmp;
        end
    end

end