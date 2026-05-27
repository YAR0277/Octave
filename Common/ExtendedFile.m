classdef ExtendedFile < YahooFile
  % Handles extended (pre- and post-market) data in YahooFile

  methods % Public

    function [obj] = ExtendedFile(varargin)

      addpath(genpath('../Finance')); % for readf

      obj = obj@YahooFile(varargin);
      obj.DataFolder = fullfile(Util.RootDataFolder,'extended');
      obj.DateFormat = 'yyyy-mm-dd HH:MM:SS';
    endfunction

    function [] = Plot(this)
      % [] = Plot
      t = this.GetTimestamp;
      x = this.GetValue;
      if isempty(x)
        fprintf('No data to plot.\n');
        return;
      endif
      this.DoPlot(t,x);
    endfunction

  endmethods %Public

  methods (Access = private)

    function [] = DoPlot(this,t,x)
      figure;
      grid on;
      hold on;

      %-----------------------------------------
      % COMPRESS TIME AXIS
      %-----------------------------------------

      % Unique trading days actually present
      trading_days = unique(floor(t));

      % Build compressed x coordinate
      tc = zeros(size(t));

      for k = 1:length(trading_days)

        d = trading_days(k);

        idx = floor(t) == d;

        % Fractional part of day
        frac = t(idx) - d;

        % Compressed day number
        tc(idx) = (k-1) + frac;

      end

      %-----------------------------------------
      % PLOTS
      %-----------------------------------------

      plot(tc,x,'--.','Color',Color.LightGrey);

      Util.AddWatermark(gca,this.Ticker);

      m = MovingAvg.CMA(x,6); % trend, 6*5min = 30min

      plot(tc,m,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);


      ticks = [];
      labels = {};

      yl = ylim;

      %-----------------------------------------
      % DAY SHADING + TICKS
      %-----------------------------------------

      for k = 1:length(trading_days)

        base = k - 1;

        % Premarket: 04:00–09:30
          patch([base+4/24 base+9.5/24 base+9.5/24 base+4/24], ...
                [yl(1) yl(1) yl(2) yl(2)], ...
                [0.95 0.95 1.0], ...
                'EdgeColor', 'none');

          % After-hours: 16:00–20:00
          patch([base+16/24 base+20/24 base+20/24 base+16/24], ...
                [yl(1) yl(1) yl(2) yl(2)], ...
                [1.0 0.95 0.95], ...
                'EdgeColor', 'none');


        % Midnight separator
        line([base base], yl, 'Color', Color.LightGrey, 'LineStyle', '--');

        % Midnight tick
        ticks(end+1) = base;
        labels{end+1} = datestr(trading_days(k), 'dd');

        % Trading-hour ticks
        special_times = [4, 9.5, 16, 20];

        for h = special_times

          ticks(end+1) = base + h/24;

          labels{end+1} = datestr(d + h/24, 'HH:MM');

        end
      end

      % Apply
      set(gca, 'xtick', ticks);
      set(gca, 'xticklabel', labels);

      xtickangle(45);

      % Replot line on top (important so shading doesn't cover it)
      plot(tc,x,'--.','Color',Color.LightGrey);

      Util.AddWatermark(gca,this.Ticker);

      plot(tc,m,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      % Duplicate y-axis on right
      ax1 = gca;

      set(ax1, ...
          'Box', 'off', ...
          'TickDir', 'out', ...
          'Layer', 'top');

      ax2 = axes( ...
          'Position', get(ax1, 'Position'), ...
          'Color', 'none', ...
          'YAxisLocation', 'right', ...
          'XAxisLocation', 'top', ...
          'XTick', [], ...
          'Box', 'off');

      set(ax2, ...
          'YLim', get(ax1, 'YLim'), ...
          'YTick', get(ax1, 'YTick'), ...
          'YTickLabel', get(ax1, 'YTickLabel'), ...
          'HitTest', 'off');

      linkaxes([ax1 ax2], 'y');
      axes(ax1);
      hold off;
    endfunction
  endmethods
endclassdef
