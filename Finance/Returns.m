% class to compute rate of returns of financial data
classdef Returns < handle

  properties
    A
    finput
    price
    returns
    timestamp
  endproperties

  methods % Public

    function obj = Returns(finput)

      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      [obj.timestamp,obj.price] = showf(finput);
    endfunction

    function [r] = GetDate(this,daynr)
      i = find( this.timestamp == daynr );
      r = datestr(this.timestamp(i));
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

    function [r] = GetReturn(this,y,q)
      if nargin == 2
        d1=datenum(strcat(num2str(y),'-01-01'),'yyyy-mm-dd');
        d2=datenum(strcat(num2str(y),'-12-31'),'yyyy-mm-dd');
      else
        d1=this.GetDayNr(q,y,'first');
        d2=this.GetDayNr(q,y,'last');
      endif
      r =this.CalcRateOfReturn(d1,d2);
    endfunction

    function [] = Plot(this)

      if isempty(this.returns)
        fprintf('The returns structure is empty. Please calculate returns and try again.\n');
        return;
      endif

      if isfield(this.returns,'quarter')
        % plot quarterly returns (QTR) at the end of the quarter, lastDay
        stem([this.returns.lastDay],[this.returns.rateOfReturn]);
      else
        % plot annual returns (YRL) at the beginning of the year, firstDay
        stem([this.returns.firstDay],[this.returns.rateOfReturn]);
      endif

      % add labels
      t = [this.returns.firstDay];
      x = [this.returns.rateOfReturn];

      labels = num2str(x(:));

      ix = x > 0;
      x(ix) = arrayfun(@(x) x+0.5, x(ix)); % adjust position for pos returns
      ix = x <= 0;
      x(ix) = arrayfun(@(x) x-0.5, x(ix)); % adjust position for neg returns

      text(t,x,labels,'FontWeight','bold','FontSize',9);

      ax = gca;
      xticks = [this.returns.year];
      set(ax,"XTick",datenum(xticks,1,1));
      datetick('x','YY','keepticks','keeplimits');

      ylabel('Rate of Return (%)');
      title(this.finput.symbol);
      xlim([this.GetDayNumber(this.returns(1).year) this.GetDayNumber(this.returns(end).year)]);
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

    function [r] = Stats(this)

      if isempty(this.returns)
        fprintf('The returns structure is empty. Please calculate returns and try again.\n');
        return;
      endif

      fprintf('Time Period: [%s,%s]\n',datestr(this.returns(1).firstDay),datestr(this.returns(end).lastDay));
      rts = [this.returns.rateOfReturn];
      fprintf('Number of Samples: %d\n',numel(rts));
      fprintf('Max. return: %.2f%%\n',max(rts));
      fprintf('Min. return: %.2f%%\n',min(rts));
      fprintf('Avg. return: %.2f%%\n',mean(rts));
      fprintf('Volatility of returns: %.2f%%\n',std(rts)); % standard deviation = volatility
      tol = 0;
      % returns > tolerance
      ix = rts > tol;
      rts_gt = rts(ix);
      fprintf('Number of Samples > %.2f: %d\n',tol,sum(ix));
      fprintf('Avg. return > %.2f: %.2f%%\n',tol,mean(rts_gt));
      % returns <= tolerance
      ix = rts <= tol;
      rts_lte = rts(ix);
      fprintf('Number of Samples <= %.2f: %d\n',tol,sum(ix));
      fprintf('Avg. return <= %.2f: %.2f%%\n',tol,mean(rts_lte));
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
        r(i).rateOfReturn=this.CalcRateOfReturn(r(i).firstDay,r(i).lastDay);
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

    function [r] = GetDayNumber(this,y)
      yearStr = num2str(y);
      dateStr = strcat(yearStr,'-01-01');
      r = datenum(dateStr,'yyyy-mm-dd');
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
