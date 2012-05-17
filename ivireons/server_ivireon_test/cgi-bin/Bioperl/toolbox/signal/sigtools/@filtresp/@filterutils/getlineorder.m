function order = getlineorder(this, basis)
%GETLINEORDER   Return the line -> filter indices.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:18:41 $

if nargin < 2, basis = 'freq'; end

order = [];

jndx = 1;
for indx = 1:length(this.Filters)
    cFilt = this.Filters(indx).Filter;
    cindx = jndx;
    jndx = jndx+1;

    % Polyphase have max(L,M) plots, which can be determined from the
    % "polyphase" method.
    if ispolyphase(cFilt) && showpoly(this)
        %         if strcmpi(basis, 'time'),
        %             p = polyphase(cFilt);
        %             jndx = jndx-1;
        %             cindx = [];



        % There are no complex polyphases for now
        %
        %             % We have to loop to look for the "complex" polyphases.
        %             for kndx = 1:size(p, 1)
        %                 cindx = [cindx jndx];
        %                 if ~isreal(p(kndx, :)),
        %                     cindx = [cindx jndx];
        %                 end
        %                 jndx = jndx+1;
        %             end
        %         else
        jndx = jndx+npolyphase(cFilt)-1;
        cindx = [cindx:jndx-1];
        %         end
    else
        % Complex filters in the time domain have 2ce as many plots.
        if strcmpi(basis, 'time') && ~isreal(cFilt)
            cindx = [cindx cindx];
        end
    end

    % Quantized have twice as many plots.
    if isquantized(cFilt) && showref(this)
        cindx = [cindx cindx];
    end

    order = [order cindx];
end

if length(this.Filters) == 1 && ...
        ~isempty(this.SOSViewOpts)
    if isa(this.Filters(1).Filter, 'dfilt.abstractsos')
        nresps = getnresps(this.SOSViewOpts, this.Filters(1).Filter);
        if length(order) == 1
            order = [1:nresps];
        else
            % We have a complex sos filter.
            order = [1:nresps];
            order = repmat(order, 1, 2);
%             order = order(:)';
        end
    end
end

% [EOF]
