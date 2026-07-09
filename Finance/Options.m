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

      cfg = Config.Instance();
      obj.RiskFreeInterestRate = cfg.get('RiskFreeInterestRate');
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

    function [call] = GetCallPrice(this,S,K,r,tau,sigma)
    % price of a call option using Black-Scholes formula
      d1 = this.fcnD1(S,K,r,tau,sigma);
      d2 = this.fcnD2(d1,tau,sigma);
      N = this.fcnNormCdf;
      call = S*N(d1) - K*exp(-r*tau)*N(d2);
    endfunction

    function [prob] = GetRiskNeutralProb(this,S,K,r,tau,sigma)
      % The risk-neutral probability that the option expires in the money: P(S>K).
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

        plot(x, Texp.lastPrice(idx), '--.', 'DisplayName', datestr(expiries(k), 'yyyy-mm-dd'));

      endfor

      yl = ylim;
      prices = this.PriceFile.GetClose;
      S = prices(end);

      hSpot = line([S S], [yl(1) yl(2)], 'Color', Color.Brown, 'LineStyle', '--');
      set(hSpot, 'HandleVisibility', 'off'); % disable legend entry

      text(S, yl(2), sprintf('S = %g', S), 'Color', Color.Brown, 'VerticalAlignment', 'top');

      % add watermark
      hwm = text(gca,0.5,0.5,this.InFile.Ticker,'units', 'normalized', 'fontsize', 50, ...
           'color', Color.LightGrey, 'horizontalalignment', 'center', 'verticalalignment', 'middle');

      xlabel('Strike Price($)');
      ylabel('Call Option Price($)');
      legend show;
      legend("location", "northeast");
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

        plot(x, Texp.lastPrice(idx), '--.', 'DisplayName', datestr(expiries(k), 'yyyy-mm-dd'));

      endfor

      yl = ylim;
      prices = this.PriceFile.GetClose;
      S = prices(end);

      hSpot = line([S S], [yl(1) yl(2)], 'Color', Color.Brown, 'LineStyle', '--');
      set(hSpot, 'HandleVisibility', 'off'); % disable legend entry

      text(S, yl(2), sprintf('S = %g', S), 'Color', Color.Brown, 'VerticalAlignment', 'top');

      % add watermark
      hwm = text(gca,0.5,0.5,this.InFile.Ticker,'units', 'normalized', 'fontsize', 50, ...
           'color', Color.LightGrey, 'horizontalalignment', 'center', 'verticalalignment', 'middle');

      xlabel('Strike Price($)');
      ylabel('Put Option Price($)');
      legend show;
      legend("location", "northwest");
    endfunction

    function [] = ShowCalls(this,numDays)

      T = this.InFile.GetOptionsByType('call');

      this.ShowOptions(T,numDays,'call');

    endfunction

    function [] = ShowPuts(this,numDays)

      T = this.InFile.GetOptionsByType('put');

      this.ShowOptions(T,numDays,'put');

    endfunction

  endmethods %Public

  methods (Access = private)

    function [] = ShowOptions(this,T,numDays,type)

      prices = this.PriceFile.GetClose;
      S = prices(end);

      dn0 = Util.GetDatenumToday;

      expiries = unique(T.expiration);
      expiries = expiries(expiries > dn0 & expiries <= dn0 + numDays);

      if length(expiries) == 0
        error('No %s options found within %d days.', type, numDays);
      endif

      expiration = [];
      strike = [];
      lastPrice = [];
      change = [];
      bid = [];
      ask = [];
      volume = [];
      openInterest = [];
      impliedVolatility = [];
      delta = [];

      for k=1:numel(expiries)

        T1 = this.InFile.GetExpiration(T, expiries(k));
        T2 = this.InFile.GetStrike(T1,S,type);

        n = height(T2);

        expiration = [expiration; repmat(expiries(k), n, 1)];
        strike = [strike;T2.strike];
        lastPrice = [lastPrice;T2.lastPrice];
        change = [change;T2.change];
        bid = [bid;T2.bid];
        ask = [ask;T2.ask];
        volume = [volume;T2.volume];
        openInterest = [openInterest;T2.openInterest];
        impliedVolatility = [impliedVolatility;T2.impliedVolatility];

        tau =  expiries(k) - Util.GetDatenumToday;
        del = this.GetDelta(S,T2.strike,this.RiskFreeInterestRate,tau,T2.impliedVolatility);
        delta = [delta;del];

      endfor

      expiration = cellstr(datestr(expiration, "yyyy-mm-dd"));
      midpoint = (bid + ask ) ./ 2;
      spread = ask - bid;
      % best measure of liquidity is the relative spread
      % l.t. 2% : excellent
      % 2-5%    : good
      % 5-10%   : fair
      % g.t. 10%: poor
      relSpread = ( spread ./ midpoint ) * 100; % in percent

      T = table(expiration,strike,lastPrice,change,midpoint,relSpread,volume,openInterest,impliedVolatility,delta);
      % https://wiki.octave.org/Function_tableprint#Usage
      prettyprint(T);

    endfunction
  endmethods
endclassdef
