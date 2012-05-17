function pctdemo_plot_blackjack(fig, S)
%PCTDEMO_PLOT_BLACKJACK Create the graphs for the Parallel Computing Toolbox 
%blackjack demos.
%   The input matrix S is expected to be of the size numHands-by-numPlayers 
%   containing the individual payoffs.
%   
%   The function creates calculates and displays the following information:
%   1) The mean fraction of the bet that is lost/won.  
%   2) A histogram of the payoffs.
%   3) For each player, we graph the timeseries of the cumulative 
%      earnings/losses.
%   4) The final earnings/losses of each player.
%   5) The combined final earnings/losses of all players.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 03:42:38 $

    if ~ishandle(fig)
        % The user closed the figure.
        return;
    end
    set(fig, 'Visible', 'on');
    figure(fig);

    % Perform all the preprocessing needed for the graphs.
    [numHands, numPlayers] = size(S);
    n = numel(S);

    % Calculate the probability of the different payoffs.
    bet = 10;
    payoffs = [-4:1 1.5 2:4]*bet;   % Possible payoffs.
    [counts, x] = hist(S(:), payoffs);
    prob = counts/n; 
    % Calculate the mean fraction of the bet that is lost/won and the confidence
    % interval.
    r = payoffs/bet;
    mu = prob*r'; % The mean.
    crit = 1.96;         % This equals norminv(.975).
    rho = crit*sqrt((prob*(r.^2)'-mu^2)/n); % The confidence interval.

    % Get the cumulative earnings/losses.
    cumulativeWinnings = cumsum(S);
    % Get the final earnings/losses of each of the players.
    finalWinnings = sort(cumulativeWinnings(end,:));
    % Get the combined final earnings/losses of all the players.
    totalWinnings = sum(cumulativeWinnings(end,:));

    % Create the histograph of payoffs.
    ax = subplot(2, 1, 1, 'parent', fig);
    bar(ax, x, prob)
    axis([-4.5*bet 4.5*bet 0 .5])
    title(ax, 'Observed probability of payoffs');
    % Show the mean fraction of the bet that is won or lost in each hand, along
    % with the confidence interval.
    xlabel(ax, sprintf(['Mean fraction of bet that is lost/won:    ', ...
                    '%6.4f \\pm %6.4f\n\n'], mu, rho));


    % Graph the timeseries of cumulative earnings/losses.
    ax = subplot(2, 1, 2, 'parent', fig);
    ymax = 100*ceil(max(abs(cumulativeWinnings(:))/100));
    % Create a reasonable color scheme for the graphs of the timeseries.
    if (numPlayers > 1)
        w = (0:numPlayers-1)'/(numPlayers-1);
        color = w*[0 0 2/3] + (1-w)*[0 2/3 0];
    else
        color = [0, 0, 1];
    end
    lines = plot(ax, (1:numHands)'/1000, cumulativeWinnings);
    % Use the color scheme we created.
    for j = 1:numPlayers
        set(lines(j), 'Color', color(j,:));
    end
    axis(ax, [0, numHands/1000, -ymax, ymax])
    title(ax, sprintf('Total winnings:    $ %d', totalWinnings))
    delta = ymax/10;
    % Alter the elements of finalWinnings to make sure we obtain unique numbers.
    yCoord = iSeparateElements(delta*round(finalWinnings/delta), delta);
    % Put labels showing the final cumulative earnings/losses of each player.
    for j = 1:numPlayers
        text(numHands/1000, yCoord(j), sprintf('  $%d', finalWinnings(j)), 'Parent', ax);
    end
    if (numPlayers > 1)
        txt = sprintf('%d players playing %d hands each', numPlayers, numHands);
    else
        txt = sprintf('1 player playing %d hands', numHands);
    end
    xlabel(ax, txt);

    drawnow;
end % End of pctdemo_plot_blackjack.


function y = iSeparateElements(y, delta)
% ISEPARATEELEMENTS  Ensure unique elements.
%   y = iSeparateElements(y, delta) alters elements of y by
%   multiples of delta to make the elements unique.

    if nargin < 2
        delta = 1; 
    end
    [y, r] = sort(y);
    while any(diff(y) == 0)
        j = find(diff(y) == 0, 1, 'first');
        k = find(y == y(j), 1, 'last');
        p = find(y < y(j), 1, 'last');
        q = find(y > y(k), 1, 'first');
        if isempty(p)
            y(1:j) = y(1:j) - delta;
        elseif isempty(q)
            y(k:end) = y(k:end) + delta;
        elseif j-p <= q-k
            y(p+1:j) = y(p+1:j) - delta;
        else
            y(k:q-1) = y(k:q-1) + delta;
        end
    end
    y(r) = y;
end % End of iSeparateElements.
