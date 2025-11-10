classdef Regression < handle
  % class to handle Regression Time Series
  %
  % References:
  % [1] Introductory Time Series with R
  %
  properties
    FcnTimeSeries % time series function
    Params        % model parameters
    SignalInput   % signal input object
    X             % time series values
    Z             % error values
  endproperties

  methods % Public

    function obj = Regression()
      % c'tor to create an Regression object, inputs are optionally p and q.

      obj.FcnTimeSeries = @(x,y,z) dot(x,y) + z;

      obj.Params = [50,3]; % intercept=50, slope=3
      sinput = Sinput;
      sinput.Height = 1;
      sinput.Length = 100;
      obj.SignalInput = sinput;
      obj.X = [];

      error = ARMA;
      error.NumTimesteps = sinput.Length;
      error.ParamAR = [0.8];
      error.Var = 20^2;
      error.Generate;
      obj.Z = error.GetValue;

      pkg load statistics;
      pkg load tsa; % time series analysis
    endfunction

    function [r] = get.Z(this)
      r = this.Z;
    endfunction

    function [] = set.Z(this,z)
      this.Z = z;
    endfunction

    function [r] = get.Params(this)
      r = this.Params;
    endfunction

    function [] = set.Params(this,v)
      this.Params = v;
    endfunction

    function [r] = GetTimestamp(this)
      % [r] = GetTimestamp() returns values of the time variable.
      r = [1:this.SignalInput.Length];
    end

    function [r] = GetValue(this)
      % [r] = GetValue() returns values of the random process.
      r = this.X;
    end

    function [] = Generate(this)
      % [] = Generate() generates the time series.
      for t = 1:this.SignalInput.Length
        this.X(t) = this.FcnTimeSeries(this.Params,[1,t],this.Z(t));
      endfor
    endfunction

    function [] = Clear(this)
      % [] = Clear() clears random process vectors.
      this.X = zeros(this.SignalInput.Length,1);
    endfunction

    function [] = Plot(this)
      % [] = Plot() plots random process.
      if isempty(this.X)
        error('generate time series by calling Generate');
      endif

      t = this.GetTimestamp;
      x = this.GetValue;

      this.DoPlot(t,x);
    endfunction

    function [] = PlotLinearLeastSquares(this)

      addpath(genpath('../Common')); % for Util

      [beta,~,~] = Util.DoLinearLeastSquares(this.GetTimestamp,this.GetValue);
      hold on;
      plot(this.GetTimestamp, beta(1) + beta(2)*this.GetTimestamp, '--.');
      hold off;
    endfunction

    function [] = Stats(this)
      % [] = Stats() calculates statistics of random process.
      if isempty(this.X)
        error('generate time series by calling Generate');
      endif

      x = this.GetValue;

      fprintf('Number of sequence values: %d\n',size(x,1));
      fprintf('Sequence Range: [%.2f,%.2f]\n',min(x),max(x));
      fprintf('Sequence Mean: %.2f\n',mean(x));
      fprintf('Sequence Std. Dev.: %.2f\n',std(x));
      fprintf('Sequence Var.: %.2f\n',var(x));
    endfunction
  endmethods % Public

  methods (Access = private)

    function [] = DoPlot(this,t,x)
      figure;
      hold on;
      plot(t,x,'--.');
      hold off;
      grid on;
      grid minor;
    endfunction
  endmethods % Private
endclassdef
