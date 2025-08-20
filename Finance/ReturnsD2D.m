classdef ReturnsD2D < Returns
  % class to compute rate of returns of financial data

  properties
    startDay    % calculate returns starting at startDay
    endDay      % calculate returns vis-a-vis endDay
  endproperties

  methods % Public

    function obj = ReturnsD2D(finput)
      % c'tor to create a ReturnsD2D object, input is an Finput object.
      obj = obj@Returns(finput);
      obj.flgPlotType = 3;
      obj.startDay = obj.timestamp(1);
      obj.endDay = Futil.GetDayToday();
    endfunction

    function [t,y] = GetReturnData(this)

      % calculates a vector of returns over all startDay <= timestamps <= endDay
      ix = this.startDay <= this.timestamp & this.timestamp <= this.endDay;
      t = this.timestamp(ix);
      price = this.data.(this.finput.dataCol);
      x = price(ix);

      n = length(t);
      y = zeros(n-1,1); % there is 1 less return than the number of timestamps
      for i=1:n-1
        y(i) = Futil.Round(((x(end)-x(i)) / x(i))*100);
      endfor
      this.returns = y; % store return data in returns

      % there is no return value for the last timestamp,
      % since that would calculate the return with itself.
      t = t(1:end-1);
    endfunction

    function [this] = SetEndDay(this,date)
      this.endDay = Futil.GetDay(date);
    endfunction

    function [this] = SetStartDay(this,date)
      this.startDay = Futil.GetDay(date);
    endfunction

  endmethods % Public
endclassdef
