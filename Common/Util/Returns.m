% class to compute rate of returns of financial data
classdef Returns < handle

  properties
    A
    price
    returns
    symbol
    timestamp
  endproperties

  methods % Public

    function obj = Returns(symbol)
      if isempty(symbol)
        obj = [];
        return;
      endif
      obj.symbol = symbol;
      filename = strcat(symbol,".csv");
      [obj.timestamp,obj.price] = showf(filename,"close"); % use closing values
    endfunction

    function [r] = GetDate(this,daynr)
      i = find( this.timestamp == daynr );
      r = datestr(this.timestamp(i));
    endfunction

    function [r] = GetPriceDate(this,date)
      daynr = datenum(date,'yyyy-mm-dd');   % daynr array contains Unix days (e.g. 737915)
      r = this.GetPrice(daynr);
    endfunction

    function [r] = GetPrice(this,daynr)
      i = find( this.timestamp == daynr );
      if ~isempty(i) % daynr is trading day
        r = this.price(i);
      else % daynr is not trading day
        ia = find( this.timestamp <= daynr, 1, 'last' );
        ib = find( this.timestamp >= daynr, 1, 'first' );
        r = mean([this.price(ia),this.price(ib)]);
      endif
    endfunction

    function [] = Plot(this)
      stem([this.returns.lastDay],[this.returns.rateOfReturn]);
      timeFormat='mm-yyyy';
      datetick('x',timeFormat,'keepticks');
      grid on;
    endfunction

    function [r] = QTR(this)

      [q1,y1] = this.GetNextQtr(this.timestamp(1));
      [qN,yN] = this.GetPrevQtr(this.timestamp(end));

      r = struct("year",0,"quarter",0,"firstDay",0,"lastDay",0,"rateOfReturn",0);
      i = 1;
      q = q1;
      y = y1;
      this.SetQtrYrMatrix(y);
      do
        r(i).year=y;
        r(i).quarter=q;
        r(i).firstDay=this.GetDayNr(q,y,'first');
        r(i).lastDay=this.GetDayNr(q,y,'last');
        r(i).rateOfReturn=this.CalcRateOfReturn(r(i).firstDay,r(i).lastDay);
        q = q + 1;
        if (q > 4)
          q = 1;
          y = y + 1;
          this.SetQtrYrMatrix(y);
        endif
        i=i+1;
      until ( q > qN && y >= yN )

      this.returns = r;
    endfunction

    function [r] = YRL(this)

      % daynr of first day of first year in timestamp
      d1=datenum(strcat(datestr(this.timestamp(1),'yyyy'),'-01-01'),'yyyy-mm-dd');
      % daynr of last day of last year in timestamp
      d2=datenum(strcat(datestr(this.timestamp(end),'yyyy'),'-12-31'),'yyyy-mm-dd');

      firstYear=str2num(datestr(this.timestamp(1),'yyyy'));
      if this.timestamp(1) > d1
        firstYear=firstYear+1; % exclude year
      endif

      lastYear=str2num(datestr(this.timestamp(end),'yyyy'));
      if this.timestamp(end) < d2
        lastYear=lastYear-1; % exclude year
      endif

      r = struct("year",0,"firstDay",0,"lastDay",0,"rateOfReturn",0);
      i = 1;
      for k=firstYear:lastYear
        r(i).year=k;
        startDate = strcat(num2str(k),'-01-01');
        endDate = strcat(num2str(k),'-12-31');
        r(i).firstDay=datenum(startDate,'yyyy-mm-dd');
        r(i).lastDay=datenum(endDate,'yyyy-mm-dd');
        r(i).rateOfReturn=this.CalcRateOfReturnDate(startDate,endDate);
        i=i+1;
      endfor

      this.returns = r;
    endfunction

    function [r] = YTD(this)
      lastYear=str2num(datestr(this.timestamp(end),'yyyy'));
      this.returns = r;
    endfunction

  endmethods % Public

  methods (Access = private)
    function [r] = CalcRateOfReturn(this,dn1,dn2)
      a = this.GetPrice(dn1);
      b = this.GetPrice(dn2);
      r = ((b-a)/a)*100;
      r = round(r*100)/100; % round to nearest 2 decimal places
    endfunction

    function [r] = CalcRateOfReturnDate(this,startDate,endDate)
      a = this.GetPriceDate(startDate);
      b = this.GetPriceDate(endDate);
      r = ((b-a)/a)*100;
      r = round(r*100)/100; % round to nearest 2 decimal places
    endfunction

    function [r] = GetDayNr(this,q,y,position)
      this.SetQtrYrMatrix(y);
      if strcmpi(position,'first')
        r = this.A(q,1);
      elseif strcmpi (position,'last')
        r = this.A(q,2);
      endif
    endfunction

    function [q,y] = GetNextQtr(this,daynr)
      year=str2num(datestr(daynr,'yyyy'));
      this.SetQtrYrMatrix(year); % matrix of quarter day numbers for year.
      found=0;
      for i=1:4
        if (this.A(i,1) <= daynr && daynr <= this.A(i,2))
          found=1;
          break;
        endif
      endfor
      % set q,y for next quarter
      if (found)
        if i==4
          q=1;
          y=year+1;
        else
          q=i+1;
          y=year;
        endif
      endif
    endfunction

    function [q,y] = GetPrevQtr(this,daynr)
      year=str2num(datestr(daynr,'yyyy'));
      this.SetQtrYrMatrix(year); % matrix of quarter day numbers for year.
      found=0;
      for i=1:4
        if (this.A(i,1) <= daynr && daynr <= this.A(i,2))
          found=1;
          break;
        endif
      endfor
      % set q,y for next quarter
      if (found)
        if i==1
          q=4;
          y=year-1;
        else
          q=i-1;
          y=year;
        endif
      endif
    endfunction

    function [] = SetQtrYrMatrix(this,yr)
      this.A = NaN(4,2);
      this.A(1,1) = datenum(strcat(num2str(yr), '-01-01'),'yyyy-mm-dd');
      this.A(1,2) = datenum(strcat(num2str(yr), '-03-31'),'yyyy-mm-dd');
      this.A(2,1) = datenum(strcat(num2str(yr), '-04-01'),'yyyy-mm-dd');
      this.A(2,2) = datenum(strcat(num2str(yr), '-06-30'),'yyyy-mm-dd');
      this.A(3,1) = datenum(strcat(num2str(yr), '-07-01'),'yyyy-mm-dd');
      this.A(3,2) = datenum(strcat(num2str(yr), '-09-30'),'yyyy-mm-dd');
      this.A(4,1) = datenum(strcat(num2str(yr), '-10-01'),'yyyy-mm-dd');
      this.A(4,2) = datenum(strcat(num2str(yr), '-12-31'),'yyyy-mm-dd');
    endfunction
  endmethods % Private
endclassdef
