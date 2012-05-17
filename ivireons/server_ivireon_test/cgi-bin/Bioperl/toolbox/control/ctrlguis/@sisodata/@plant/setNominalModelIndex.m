function setNominalModelIndex(this,Idx)
%setNominalModelIndex  Sets the Nominal Model Index

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:22:27 $

if (Idx > numel(this.getP)) || (Idx < 0)
    ctrlMsgUtils.error('Controllib:General:UnexpectedError', ...
        sprintf('Nominal model index must be a positive value less than %d',numel(this.getP)))
else
    this.NominalIdx = Idx;
end
