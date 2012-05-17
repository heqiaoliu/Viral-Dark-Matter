function bool = isGainBlock(this)
% Returns true if compensator is pure gain block
% used by pzeditor

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:46:45 $

for ct=1:length(this)
    bool(ct) = false;
    if isa(this(ct),'sisodata.TunedZPK') && ~isempty(this(ct).Constraints) ...
        && (this(ct).Constraints.MaxZeros == 0) && (this(ct).Constraints.MaxPoles == 0)
        bool(ct) = true;
    end
end
