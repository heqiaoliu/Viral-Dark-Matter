function bool = isDeletePZAllowed(this,PZGroup)
%ISDELTEPZALLOWED  checks if a pzgroup can be deleted from the compensator.

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2006/01/26 01:46:34 $

if isTunable(this)
    Constraints = this.Constraints;
    if isempty(Constraints) ||  ...
            ~isfield(Constraints,'allowImproper') || ...
            (isfield(Constraints,'allowImproper') && Constraints.allowImproper)
        bool = true;
    else
        % Check if deletion makes it inproper
        % only need to check real and complex
        switch PZGroup.Type
            case 'Real'
                if isempty(PZGroup.Pole)
                    bool = true;
                else
                    [z,p] = getPZ(this);
                    if length(z) < length(p)
                        bool = true;
                    else
                        bool = false;
                    end
                end
            case 'Complex'
                if isempty(PZGroup.Pole)
                    bool = true;
                else
                    [z,p] = getPZ(this);
                    if (length(z)+1) < length(p)
                        bool = true;
                    else
                        bool = false;
                    end
                end
            otherwise
                bool = true;
        end
    end

else
    bool = false;
end


