function x = exist( obj, labidxs )
%EXIST Check whether Composite is defined on lab
%   H = EXIST(C, LABIDX) returns true if the entry in Composite C has a
%   defined value on the lab with labindex LABIDX, false otherwise.  In the
%   general case where LABIDX is an array, the output H is an array of the
%   same size as LABIDX, and H(I) indicates whether the Composite entry
%   LABIDX(I) has a defined value.
%
%   EXIST(C) is equivalent to EXIST(C, 1:LENGTH(C)).
%
%   If EXIST(C, LABIDX) returns true, C(LABIDX) does not throw an error,
%   provided the values of C on those labs are serializable.
%
%   The function throws an error if:
%   - The lab indices are invalid.
%
%   Example:
%   % Check where the Composite entries are defined, and get all those values:
%   spmd
%      if rand() > 0.5
%          c = labindex;
%      end
%   end
%   ind = exist(c);
%   cvals = c(ind);
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:17 $

% True if we either have a valid key, or a client-side value.
    if nargin == 1
        labidxs = 1:length( obj );
    end
    
    labidxsV = labidxs(:);

    % Arg check - need a vector of integers between 1 and numel
    if islogical( labidxsV )
        if length( labidxsV ) <= length ( obj )
            % For logical exist - we cannot possibly reshape the output to match the
            % input, so default to a row vector

            labidxs  = find( labidxsV ); % convert logical -> indexes
            labidxsV = labidxs(:);       % Re-create the column
            labidxs  = labidxsV.';       % create the row for defining the output shape
        else
            error( 'distcomp:spmd:CompositeExist', ...
                   'Too many values specified for exist' );
        end
    elseif isnumeric( labidxsV )
        if all( labidxsV <= length( obj ) ) && ...
                all( labidxsV >= 1 ) && ...
                all( labidxsV == round( labidxsV ) )
            % ok
        else
            error( 'distcomp:spmd:CompositeExist', ...
                   ['The numeric argument to Composite.exist must be an array of integers \n', ...
                    'between 1 and the length of the Composite (length %d).'], length( obj ) );
        end
    else
        error( 'distcomp:spmd:CompositeExist', ...
               'The argument to Composite.exist must either be numeric or logical' );
    end
    
    if ~obj.isResourceSetOpen()
        % Pool closed, exist is false everywhere
        x = false( size( labidxsV ) );
    elseif obj.ClientValueValid
        % Got a client value, so exist is true everywhere
        x = true( size( labidxsV ) );
    else
        % Must check by key
        gotKey = ~cellfun( @isempty, obj.KeyVector );
        x = gotKey( labidxsV );
    end
    % Massage the shape to match the input
    x = reshape( x, size( labidxs ) );
end
