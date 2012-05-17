function StateOrder = getNonAccelReferenceStateBlockNames(this)
% GETNONACCELREFERENCESTATEBLOCKNAMES Get a cell array list of the
% non-accelerated model reference state block path names.
 
% Author(s): John W. Glass 05-Nov-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/12/04 23:19:22 $

StateOrder = get(this.States,{'Block'});

for ct = numel(StateOrder):-1:1
    if ~isempty(this.States(ct).StateName)
        StateOrder{ct} = this.States(ct).StateName;
    else
        if this.States(ct).inReferencedModel
            if opcond.isAccelReferenceStateBlockPath(StateOrder{ct})
                StateOrder(ct) = [];
            end
        end
    end
end