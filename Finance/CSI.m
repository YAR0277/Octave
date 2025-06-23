classdef CSI < handle
  % Comparative Strength Index
  % https://en.wikipedia.org/wiki/Relative_strength_index
  % https://www.investopedia.com/terms/r/rsi.asp

  properties
    data      % struct for input data
    finput    % Finput class object
    price     % x - prices of investment
    refFinput % reference Finput class object
    refPrice  % reference prices
    refSymbol % reference symbol
    refTimestamp % reference timestamp
    timestamp % t - timestamp of prices
  endproperties

  methods % Public

    function obj = CSI(finput)
      % c'tor to create an CSI object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      obj.data = readf(finput);
      obj.timestamp = obj.data.Date;
      obj.price = obj.data.(finput.dataCol);
    endfunction

    function [] = AddReference(this,finput)
      dataRef = readf(finput);
      this.refFinput = finput;
      this.refPrice = dataRef.(finput.dataCol);
      this.refSymbol = finput.symbol;
      this.refTimestamp = dataRef.Date;
    endfunction

    function [] = Stats(this)

      [~,ia,ib] = intersect(this.timestamp,this.refTimestamp);
      x = this.price(ia);

      dx = diff(x);
      u(dx  > 0) = 1;
      u(dx <= 0) = 0;
      d(dx  < 0) = 1;
      d(dx >= 0) = 0;

      y = this.refPrice(ib);

      dy = diff(y);
      uref(dy  > 0) = 1;
      uref(dy <= 0) = 0;
      dref(dy  < 0) = 1;
      dref(dy >= 0) = 0;

      fprintf('Symbol: %s\n',this.finput.symbol);
      fprintf('Time Period: [%s,%s]\n',datestr(this.refTimestamp(1)),datestr(this.refTimestamp(end)));
      fprintf('Number of Samples: %s(%d), %s(%d)\n',this.finput.symbol,numel(x),this.refSymbol,numel(y));

      if numel(dx) ~= numel(dy)
        fprintf('Unequal sizes: dx=%d, dy=%d\n',numel(dx),numel(dy));
        return;
      endif

      s = sum(u & uref) / sum(uref);
      fprintf('Prob(%s Up|%s Up): %.2f\n',this.finput.symbol,this.refSymbol,s);

      s = sum(d & uref) / sum(uref);
      fprintf('Prob(%s Down|%s Up): %.2f\n',this.finput.symbol,this.refSymbol,s);

      s = sum(u & dref) / sum(dref);
      fprintf('Prob(%s Up|%s Down): %.2f\n',this.finput.symbol,this.refSymbol,s);

      s = sum(d & dref) / sum(dref);
      fprintf('Prob(%s Down|%s Down): %.2f\n',this.finput.symbol,this.refSymbol,s);

    endfunction

  endmethods %Public
endclassdef
