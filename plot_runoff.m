function [ax_q, ax_prcp] = plot_runoff(prcp, Qobs, Qsim) % ylim, ylim2
    %% TODO:
    % 1. add an example at here
    % 2. change `plotyy` to `yyaxis`
    arguments
        prcp
        Qobs
        Qsim
        % ylim
        % ylim2
    end

    x = 1:length(Qobs);
    fontname = 'Microsoft YaHei';

    pos = get(0, 'ScreenSize'); % screensize
    figure('color', 'w', 'position', pos);
    plot(x, Qsim - Qobs, 'g-', 'linewidth', 2); hold on; % Q_bias
    plot(x, Qsim, 'r-', 'linewidth', 2)

    [haxes, hline, hbar] = plotyy(x, Qobs, x, prcp, 'plot', 'bar');
    ax_q = haxes(1);
    ax_prcp = haxes(2);
    % set(hline1,'linestyle',':')

    %% bar adjust
    set(hbar, 'FaceColor', 'b', 'EdgeColor', 'b')

    %% plot adjust
    axes(ax_q)
    set(gca, 'fontname', fontname, 'fontsize', 11)
    % set(gca, 'ylim', [-300 900])
    % set(gca, 'ytick', -300:100:500)
    % set(gca, 'yticklabel', {'-300', '-200', '-100', '0', '100', '200', '300', '400', '500'})
    set(gca, 'xticklabel', {''})
    ylabel('Q (m^3/s)')
    legend('Bias', 'Q_sim', 'Qobs', 'location', 'east')
    set(hline, 'linewidth', 1.5, 'color', 'b', 'lineStyle', '--')
    grid on
    
    axes(ax_prcp)
    axis ij
    set(gca, 'fontname', fontname, 'fontsize', 10)
    set(gca, 'YAxisLocation', 'left')
    % set(gca, 'ylim', [0, 120])
    % set(gca, 'ytick', 0:5:30)
    % set(gca, 'yticklabel', {'0', '5', '10', '15', '20', '25', '30'})
    ylabel('Precipitation (mm/h)', 'fontname', fontname, 'fontsize', 12)
    set(get(gca, 'ylabel'), 'position', [-20 18 10])
    xlabel('Time', 'fontname', fontname, 'fontsize', 12)

    axes(ax_q)
    % title(title, 'fontname', fontname, 'fontsize', 14)
end
