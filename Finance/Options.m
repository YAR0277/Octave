classdef Options < handle
  % Options -
  % https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black%E2%80%93Scholes_formula

  properties
    fcnNormCdf
    fcnNormPdf
    fcnD1
    fcnD2
    InFile
    RiskFreeInterestRate
    PriceFile
  endproperties

  methods % Public

    function obj = Options(inFile)
      % c'tor to create a Price object, input is an FidelityFile object.
      if ~isa(inFile, 'OptionsFile')
        error('Invalid input file class (%s)\n',class(inFile));
      endif

      baseFolder = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
      dataFolder = fullfile(baseFolder,'data','finance');
      equityFolder = fullfile(dataFolder,'equity');
      etfFolder = fullfile(dataFolder,'etf');

      obj.InFile = inFile;
      obj.RiskFreeInterestRate = 0.02;
      obj.fcnNormCdf = @(x) normcdf(x);
      obj.fcnNormPdf = @(x) normpdf(x);
      obj.fcnD1 = @(S,K,r,tau,sigma) (log(S./K) + (r + (sigma.^2)./2).*tau) ./ (sigma .* sqrt(tau));
      obj.fcnD2 = @(y,tau,sigma) y - (sigma .* sqrt(tau));

      filename = regexprep(inFile.FileName, '-o\.csv$', '-d.csv'); % 'WDC-o.csv' -> 'WDC-d.csv'
      y = YahooFile;
      if exist(fullfile(equityFolder,filename), "file") == 2
        y.SetFolder('equity');
      elseif exist(fullfile(etfFolder,filename), "file") == 2
        y.SetFolder('etf');
      else
        error("File not found: %s\n",filename);
      endif
      y.LoadFile(filename);
      obj.PriceFile = y;

      pkg load statistics;
      format long;
    endfunction

    function [delta] = GetDelta(this,S,K,r,tau,sigma)
      d1 = this.fcnD1(S,K,r,tau,sigma);
      N = this.fcnNormCdf;
      delta = N(d1);
    endfunction

    function [gamma] = GetGamma(this,S,K,r,tau,sigma)
      d1 = this.fcnD1(S,K,r,tau,sigma);
      phi = this.fcnNormPdf;
      gamma = phi(d1)./(S.*sigma.*sqrt(tau));
    endfunction

    function [theta] = GetTheta(this,S,K,r,tau,sigma)
      d1 = this.fcnD1(S,K,r,tau,sigma);
      d2 = this.fcnD2(d1,tau,sigma);
      N = this.fcnNormCdf;
      phi = this.fcnNormPdf;
      theta = -sigma.*S.*phi(d1)./(2.*sqrt(tau)) - r.*K.*exp(-r.*tau).*N(d2);
    endfunction

    function [vega] = GetVega(this,S,K,r,tau,sigma)
      d1 = this.fcnD1(S,K,r,tau,sigma);
      phi = this.fcnNormPdf;
      vega = S.*phi(d1).*sqrt(tau);
    endfunction

    function [volatility,data] = CalcVolatility(this,C,S,K,r,tau)
      % function to estimate volatility via Newton's method given call price C
      % https://ianwang2002.github.io/FinMath_model.pdf

      sigma = 1;
      tolerance = 1e-6;
      i = 0;
      while true
        i = i + 1;
        price = this.GetCallPrice(S,K,r,tau,sigma);
        vega = this.GetVega(S,K,r,tau,sigma);

        if vega == 0
          break;
        endif

        error = (price - C) / vega;
        data(i,:) = [sigma, price, error];

        if abs(error) < tolerance
          break;
        endif

        sigma = sigma - error;
      endwhile

      volatility = sigma;
    endfunction

    function [put] = GetCallPrice(this,S,K,r,tau,sigma)
    % price of a put option using Black-Scholes formula
      d1 = this.fcnD1(S,K,r,tau,sigma);
      d2 = this.fcnD2(d1,tau,sigma);
      N = this.fcnNormCdf;
      put = S*N(d1) - K*exp(-r*tau)*N(d2);
    endfunction

    function [prob] = GetRiskNeutralProb(this,S,K,r,tau,sigma)
      % The risk-neutral probability that the put expires in the money: P(S>K).
      d1 = this.fcnD1(S,K,r,tau,sigma);
      d2 = this.fcnD2(d1,tau,sigma);
      N = this.fcnNormCdf;
      prob = N(d2);
    endfunction

    function [put] = GetPutPrice(this,S,K,r,tau,sigma)
    % price of a put option using Black-Scholes formula
      d1 = this.fcnD1(S,K,r,tau,sigma);
      d2 = this.fcnD2(d1,tau,sigma);
      N = this.fcnNormCdf;
      put = -S*N(-d1) + K*exp(-r*tau)*N(-d2);
    endfunction

    function [] = PlotCalls(this,numDays)

      T = this.InFile.GetOptionsByType('call');

      dn0 = Util.GetDatenumToday;

      expiries = unique(T.expiration);
      expiries = expiries(expiries >= dn0 & expiries <= dn0 + numDays);

      figure;
      hold on;

      for k=1:numel(expiries)
        Texp = this.InFile.GetExpiration(T, expiries(k));

        [x,idx] = sort(Texp.strike);

        plot(x, Texp.lastPrice(idx), '--', 'DisplayName', datestr(expiries(k), 'yyyy-mm-dd'));

      endfor

      yl = ylim;
      prices = this.PriceFile.GetClose;
      S = prices(end);

      hSpot = line([S S], [yl(1) yl(2)], 'Color', Color.Red, 'LineStyle', '--');
      set(hSpot, 'HandleVisibility', 'off'); % disable legend entry

      text(S, yl(2), sprintf('S = %g', S), 'Color', Color.Red, 'VerticalAlignment', 'top');

      % add watermark
      hwm = text(gca,0.5,0.5,this.InFile.Ticker,'units', 'normalized', 'fontsize', 50, ...
           'color', Color.LightGrey, 'horizontalalignment', 'center', 'verticalalignment', 'middle');

      xlabel('K');
      ylabel('Option Price');
      legend show;

    endfunction

    function [] = PlotPuts(this,numDays)

      T = this.InFile.GetOptionsByType('put');

      dn0 = Util.GetDatenumToday;

      expiries = unique(T.expiration);
      expiries = expiries(expiries >= dn0 & expiries <= dn0 + numDays);

      figure;
      hold on;

      for k=1:numel(expiries)
        Texp = this.InFile.GetExpiration(T, expiries(k));

        [x,idx] = sort(Texp.strike);

        plot(x, Texp.lastPrice(idx), '--', 'DisplayName', datestr(expiries(k), 'yyyy-mm-dd'));

      endfor

      yl = ylim;
      prices = this.PriceFile.GetClose;
      S = prices(end);

      hSpot = line([S S], [yl(1) yl(2)], 'Color', Color.Red, 'LineStyle', '--');
      set(hSpot, 'HandleVisibility', 'off'); % disable legend entry

      text(S, yl(2), sprintf('S = %g', S), 'Color', Color.Red, 'VerticalAlignment', 'top');

      % add watermark
      hwm = text(gca,0.5,0.5,this.InFile.Ticker,'units', 'normalized', 'fontsize', 50, ...
           'color', Color.LightGrey, 'horizontalalignment', 'center', 'verticalalignment', 'middle');

      xlabel('K');
      ylabel('Option Price');
      legend show;
    endfunction

  endmethods %Public

  methods (Access = private)

  endmethods
endclassdef
