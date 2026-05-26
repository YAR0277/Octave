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

      plot(t,x,'--.','Color',Color.LightGrey);
      Util.AddWatermark(gca,this.Ticker);
      m = MovingAvg.CMA(x,6); % trend, 6*5min = 30min
      plot(t,m,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

      d0 = floor(min(t));
      d1 = floor(max(t));

      ticks = [];
      labels = {};

      % LOCK axes after initial plot
      xlim([min(t) max(t)]);
      yl = ylim;

      for d = d0:d1

        % Premarket: 04:00–09:30
          patch([d+4/24 d+9.5/24 d+9.5/24 d+4/24], ...
                [yl(1) yl(1) yl(2) yl(2)], ...
                [0.95 0.95 1.0], ...
                'EdgeColor', 'none');

          % After-hours: 16:00–20:00
          patch([d+16/24 d+20/24 d+20/24 d+16/24], ...
                [yl(1) yl(1) yl(2) yl(2)], ...
                [1.0 0.95 0.95], ...
                'EdgeColor', 'none');


        % Midnight separator
        line([d d], yl, 'Color', Color.LightGrey, 'LineStyle', '--');

        % Midnight tick
        ticks(end+1) = d;
        labels{end+1} = datestr(d, 'dd');

        % Trading-hour ticks
        special_times = [4, 9.5, 16, 20];

        for h = special_times

          tt = d + h/24;

          ticks(end+1) = tt;
          labels{end+1} = datestr(tt, 'HH:MM');

        end
      end

      % Keep only visible ticks
      idx = (ticks >= min(t)) & (ticks <= max(t));

      ticks = ticks(idx);
      labels = labels(idx);

      % Apply
      set(gca, 'xtick', ticks);
      set(gca, 'xticklabel', labels);

      xtickangle(45);

      % Replot line on top (important so shading doesn't cover it)
      plot(t,x,'--.','Color',Color.LightGrey);
      Util.AddWatermark(gca,this.Ticker);
      plot(t,m,'--.','MarkerSize',Constant.PlotMarkerSize,'LineWidth',Constant.PlotLineWidth);

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
