function y = initInstanceNumber(this, mode)
%INITINSTANCENUMBER Static storage for MPlay instance numbers
% Vector of logical entries; 0=unused, 1=used
% mode='alloc': allocates next instance number
%      'free': returns current instance number back to pool
%      'count': return total number of allocated instances

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/09 19:34:58 $

% Logical vector of instance numbers
%   0: index is free for use
%   1: index is being used
persistent instance_numbers

switch mode
    case 'alloc'
        % Allocate first "empty" (zero-valued) slot in vector
        y = find(~[instance_numbers 0],1);
        % Take next available slot:
        instance_numbers(y) = 1;
        this.InstanceNumber = y;  % record instance number in object
        
    case 'free'
        % Return instance number back to pool
        y = this.InstanceNumber;
        if (y<1) || (y>numel(instance_numbers))
            errTitle = [this.getAppName(true), ' Error'];
            uiscopes.errorHandler(sprintf('Instance number (%d) out of range.', y),errTitle);
        end
        instance_numbers(y) = 0;
        
    case 'count'
        % return total # of allocated instance numbers
        y = sum(instance_numbers);

    otherwise
        error(generatemsgid('InvalidOption'),...
            'Unrecognized option %s', mode);
end

mlock

% [EOF]
