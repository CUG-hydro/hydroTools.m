function writefig(outfile, width, height, tight_scale)

    arguments
        outfile = "Plot.pdf"
        width = 10
        height = 6
        tight_scale = 0.8
    end

    % tight_plot(tight_scale)
    h = gcf;
    set(h, 'PaperUnits', 'inches');
    set(h, 'PaperPositionMode', 'auto');
    set(h, 'Units', 'inches');
    % set(h,'PaperSize',[width height]); %set the paper size to what you want
    size = [width, height];
    % screenposition = get(gcf,'Position');
    set(gcf, 'PaperPosition', [0 0 size], ...
        'PaperSize', size);

    % , '-bestfit'
    print(h, outfile, '-dpdf') % then print it
end

function tight_plot(tight_scale)
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset * tight_scale;
    left = outerpos(1) + ti(1) / 2;
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
end
