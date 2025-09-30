classdef CSI < handle
  % Comparative Strength Index
  % https://en.wikipedia.org/wiki/Relative_strength_index
  % https://www.investopedia.com/terms/r/rsi.asp

  properties
    data      % struct for input data
    fidelityFile    % FidelityFile class object
    price     % x - prices of investment
    refFinput % reference FidelityFile class object
    refPrice  % reference prices
    refSymbol % reference symbol
    refTimestamp % reference timestamp
    timestamp % t - timestamp of prices
  endproperties

  methods % Public

    function obj = CSI(fidelityFile,refInput)
      % c'tor to create an CSI object, input is an FidelityFile object.
      if ~isa(fidelityFile, 'FidelityFile') || ~isa(refInput, 'FidelityFile')
        return;
      endif

      obj.fidelityFile = fidelityFile;
      obj.data = readf(fidelityFile);
      obj.timestamp = obj.data.Date;
      obj.price = obj.data.(fidelityFile.dataCol);
      obj.AddReference(refInput);
    endfunction

    function [] = AddReference(this,fidelityFile)
      dataRef = readf(fidelityFile);
      this.refFinput = fidelityFile;
      this.refPrice = dataRef.(fidelityFile.dataCol);
      this.refSymbol = fidelityFile.symbol;
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

      fprintf('Symbol: %s\n',this.fidelityFile.symbol);
      fprintf('Time Period: [%s,%s], Time Step: %s, Nr. Samples: %s(%d), %s(%d)\n',...
        datestr(this.refTimestamp(1)),datestr(this.refTimestamp(end)),...
        Util.GetTimeStep(this.timestamp),...
        this.fidelityFile.symbol,numel(x),this.refSymbol,numel(y));

      if numel(dx) ~= numel(dy)
        fprintf('Unequal sizes: dx=%d, dy=%d\n',numel(dx),numel(dy));
        return;
      endif

      s1 = sum(u & uref) / sum(uref);
      s2 = sum(d & uref) / sum(uref);
      s3 = sum(u & dref) / sum(dref);
      s4 = sum(d & dref) / sum(dref);
      fprintf('Prob(Up|Up)=%.2f, Prob(Dn|Up)=%.2f, Prob(Up|Dn)=%.2f, Prob(Dn|Dn)=%.2f\n',s1,s2,s3,s4);

    endfunction

  endmethods %Public
endclassdef
