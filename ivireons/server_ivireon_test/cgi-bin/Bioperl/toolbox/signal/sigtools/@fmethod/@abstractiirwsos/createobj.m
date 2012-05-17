function Hd = createobj(this,coeffs)
%CREATEOBJ   Create the filter object from the coefficients.

%   Author(s): R. Losada
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:40 $

struct = get(this, 'FilterStructure');

if any(strcmpi(struct,{'df1sos','df2sos','df1tsos','df2tsos'})),
    Hd = feval(['dfilt.' struct], coeffs{:});
    sosscale(this, Hd); 
    % Discard trivial sections 
    s = Hd.sosMatrix;
    g = Hd.ScaleValues;
    idx = false(nsections(Hd),1);
    for i=1:numel(idx),
        if all(s(i,:) == [1 0 0 1 0 0]),
            idx(i) = true;        % Section i is [1 0 0 1 0 0]
            g(i+1) = g(i)*g(i+1); % Combine scale value of section i with scale value of section i+1
        end
    end
    s(idx,:)=[];
    g(idx) = [];
    % If no section left, restore a trivial section but keep the
    % combined scale value
    if isempty(s)
        s = [1 0 0 1 0 0];
    end
    Hd.sosMatrix = s;
    Hd.ScaleValues = g;
else
    Hd = coupledallpass(this,struct,coeffs{1});
end

% [EOF]
