classdef Returns < handle
  % class to compute rate of returns of financial data

  properties
    finput      % Reference to Finput class
    price       % x - prices of investment
    returns     % rate of return structure
    timestamp   % t - timestamp of prices
    timestep    % time interval of price data {'day','week','month','quarter'}
  endproperties

  properties (Access=private)
    A           % days, weeks, months or quarters in a year matrix
  endproperties

  methods % Public

    function obj = Returns(finput)
      % c'tor to create a Returns object, input is an Finput object.
      if ~isa(finput, 'Finput')
        return;
      endif

      obj.finput = finput;
      [obj.timestamp,obj.price,~] = showf(finput);
      obj.timestep = obj.SetTimeStep(obj.timestamp);
    endfunction

    function [] = Bar(this)
      % plots rate of returns
      if isempty(this.returns)
        fprintf('The returns structure is empty. Please calculate returns and try again.\n');
        return;
      endif

      if isfield(this.returns,'month')
        this.BarYTD();
        return;
      endif

      figure;
      if isfield(this.returns,'quarter')
        % plot quarterly returns (QTR) at the end of the quarter, lastDay
        bar([this.returns.lastDay],[this.returns.rateOfReturn]);
      else
        % plot annual returns (YRL) at the beginning of the year, firstDay
        bar([this.returns.firstDay],[this.returns.rateOfReturn]);
      endif

      this.DoVolatility();

      ax = gca;
      xticks = [this.returns.year];
      set(ax,"XTick",datenum(xticks,1,1));
      datetick('x','YY','keepticks','keeplimits');

      ylabel('Rate of Return (%)');
      title(this.finput.symbol);
      xlim([this.GetDayNumber(this.returns(1).year) this.GetDayNumber(this.returns(end).year)]);
      grid on;

      this.DoLabels(-2,1);

    endfunction

    function [] = BarYTD(this)
      % plot monthly returns as bar plot

      figure;
      bar([this.returns.lastDay],[this.returns.rateOfReturn]); % at the end of each month, lastDay

      numReturns = numel([this.returns.rateOfReturn]);

      ax = gca;
      xticks = [this.A(1:numReturns,2)]; % 2 = lastDay
      set(ax,"XTick",xticks);
      datetick('x','YY-mm','keepticks','keeplimits');

      xlim([this.A(1,2) this.A(numReturns,2)]);

      ylabel('Rate of Return (%)');
      title(this.finput.symbol);
      grid on;
    endfunction

    function [] = GetDateRange(this)
      % prints date range of input data to console
      sDate = this.GetDate(this.timestamp(1));
      eDate = this.GetDate(this.timestamp(end));
      fprintf('Date Range is [%s(%d), %s(%d)]\n',sDate,this.timestamp(1),eDate,this.timestamp(end));
    endfunction

    function [r] = GetPrice(this,daynr)
      % returns price for a given day number
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
      % returns rate of return: GetReturn(1999), GetReturn(1999,3)
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
      % plots rate of returns
      if isempty(this.returns)
        fprintf('The returns structure is empty. Please calculate returns and try again.\n');
        return;
      endif

      if isfield(this.returns,'month')
        this.PlotYTD();
        return;
      endif

      figure;
      if isfield(this.returns,'quarter')
        % plot quarterly returns (QTR) at the end of the quarter, lastDay
        stem([this.returns.lastDay],[this.returns.rateOfReturn]);
      else
        % plot annual returns (YRL) at the beginning of the year, firstDay
        stem([this.returns.firstDay],[this.returns.rateOfReturn]);
      endif

      ax = gca;
      xticks = [this.returns.year];
      set(ax,"XTick",datenum(xticks,1,1));
      datetick('x','YY','keepticks','keeplimits');

      ylabel('Rate of Return (%)');
      title(this.finput.symbol);
      xlim([this.GetDayNumber(this.returns(1).year) this.GetDayNumber(this.returns(end).year)]);
      grid on;

      this.DoLabels(-1,2);

    endfunction

    function [] = PlotYTD(this)
      % plot monthly returns as stem plot

      figure;
      stem([this.returns.lastDay],[this.returns.rateOfReturn]); % at the end of each month, lastDay

      numReturns = numel([this.returns.rateOfReturn]);

      [xticks,fmt] = this.GetTimeTicks();
      ax = gca;
      set(ax,"XTick",xticks);
      datetick('x',fmt,'keepticks','keeplimits');

      xlim([this.A(1,2) this.A(numReturns,2)]);

      ylabel('Rate of Return (%)','FontSize',16);
      title(this.finput.symbol,'FontSize',16);
      grid on;
    endfunction

    function [r] = QTR(this)
      % calculates quarterly rate of returns
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
      % calculates statistics on returns
      if isempty(this.returns)
        fprintf('The returns structure is empty. Please calculate returns and try again.\n');
        return;
      endif

      fprintf('Symbol: %s\n',this.finput.symbol);
      fprintf('Time Period: [%s,%s]\n',datestr(this.returns(1).firstDay),datestr(this.returns(end).lastDay));
      rts = [this.returns.rateOfReturn];
      fprintf('Number of Samples: %d\n',numel(rts));
      fprintf('Max. return: %.2f%%\n',max(rts));
      fprintf('Min. return: %.2f%%\n',min(rts));
      fprintf('Avg. return: %.2f%%\n',mean(rts));
      fprintf('Total return: %.2f%%, APR=%.2f%%\n',sum(rts),sum(rts)*(365/numel(rts)));
      fprintf('Volatility of returns: %.2f%%\n',std(rts)); % standard deviation = volatility
      tol = 0;
      % returns > tolerance
      ix = rts >= tol;
      fprintf('Number of Returns >= %.2f: %d (avg. return %.2f%%)\n',tol,sum(ix),mean(rts(ix)));
      % returns <= tolerance
      ix = rts <= tol;
      fprintf('Number of Returns <= %.2f: %d (avg. return %.2f%%)\n',tol,sum(ix),mean(rts(ix)));
      % returns >= volatility
      ix = rts >= std(rts);
      fprintf('Number of Returns >= %.2f: %d (avg. return %.2f%%)\n',std(rts),sum(ix),mean(rts(ix)));
      % returns <= -volatility
      ix = rts <= -std(rts);
      fprintf('Number of Returns <= %.2f: %d (avg. return %.2f%%)\n',-std(rts),sum(ix),mean(rts(ix)));

    endfunction

    function [r] = YRL(this)
      % calculates yearly rate of returns

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
      % calculates year to date rate of returns
      switch this.timestep
        case 'day'
          r = this.CalcYtdDay();
        case 'week'
          r = this.CalcYtdWeek();
        case 'month'
          r = this.CalcYtdMonth();
        case 'quarter'
          r = this.CalcYtdQuarter();
        otherwise
      endswitch
    endfunction

  endmethods % Public

  methods (Access = private)

    function [r] = CalcYtdDay(this)
      % calculates year to date rate of returns for timestep='day' data
      currYear = str2num(datestr(now,'yyyy'));
      returnYear = [str2num(datestr(this.timestamp,'yyyy'))];
      ix = returnYear == currYear;
      numDays = sum(ix);

      if numDays == 0
        return;
      endif

      r = struct("year",0,"day",0,"firstDay",0,"lastDay",0,"rateOfReturn",0);
      i = 1;
      this.SetDayYrMatrix(currYear);
      do
        r(i).year=currYear;
        r(i).day=i;
        r(i).firstDay=this.A(i,1);
        r(i).lastDay=this.A(i,2);
        r(i).rateOfReturn=this.CalcRateOfReturn(r(i).firstDay,r(i).lastDay);
        i = i + 1;
      until (i > numDays)

      this.returns = r;
    endfunction

    function [r] = CalcYtdWeek(this)
      % calculates year to date rate of returns for timestep='week' data
      currYear = str2num(datestr(now,'yyyy'));
      returnYear = [str2num(datestr(this.timestamp,'yyyy'))];
      ix = returnYear == currYear;
      numWeeks = sum(ix);

      if numWeeks == 0
        return;
      endif

      r = struct("year",0,"week",0,"firstDay",0,"lastDay",0,"rateOfReturn",0);
      i = 1;
      this.SetWeekYrMatrix(currYear);
      do
        r(i).year=currYear;
        r(i).week=i;
        r(i).firstDay=this.A(i,1);
        r(i).lastDay=this.A(i,2);
        r(i).rateOfReturn=this.CalcRateOfReturn(r(i).firstDay,r(i).lastDay);
        i = i + 1;
      until (i > numWeeks)

      this.returns = r;
    endfunction

    function [r] = CalcYtdMonth(this)
      % calculates year to date rate of returns for timestep='month' data
      currYear = str2num(datestr(now,'yyyy'));
      returnYear = [str2num(datestr(this.timestamp,'yyyy'))];
      ix = returnYear == currYear;
      numMonths = sum(ix);

      if numMonths == 0
        return;
      endif

      r = struct("year",0,"month",0,"firstDay",0,"lastDay",0,"rateOfReturn",0);
      i = 1;
      this.SetMonthYrMatrix(currYear);
      do
        r(i).year=currYear;
        r(i).month=i;
        r(i).firstDay=this.A(i,1);
        r(i).lastDay=this.A(i,2);
        r(i).rateOfReturn=this.CalcRateOfReturn(r(i).firstDay,r(i).lastDay);
        i = i + 1;
      until (i > numMonths)

      this.returns = r;
    endfunction

    function [r] = CalcYtdQuarter(this)
      % calculates year to date rate of returns for timestep='quarter' data
      currYear = str2num(datestr(now,'yyyy'));
      returnYear = [str2num(datestr(this.timestamp,'yyyy'))];
      ix = returnYear == currYear;
      numQuarters = sum(ix);

      if numQuarters == 0
        return;
      endif
      r = struct("year",0,"quarter",0,"firstDay",0,"lastDay",0,"rateOfReturn",0);
      i = 1;
      this.SetQtrYrMatrix(currYear);
      do
        r(i).year=currYear;
        r(i).quarter=i;
        r(i).firstDay=this.A(i,1);
        r(i).lastDay=this.A(i,2);
        r(i).rateOfReturn=this.CalcRateOfReturn(r(i).firstDay,r(i).lastDay);
        i = i + 1;
      until (i > numQuarters)

      this.returns = r;
    endfunction

  function [] = DoLabels(this,dt,dx)
      t = [this.returns.firstDay];
      x = [this.returns.rateOfReturn];

      labels = num2str(x(:));

      t = arrayfun(@(t) t+dt, t(:)); % adjust t position

      ix = x > 0;
      x(ix) = arrayfun(@(x) x+dx, x(ix)); % adjust x position for pos returns
      ix = x <= 0;
      x(ix) = arrayfun(@(x) x-dx, x(ix)); % adjust x position for neg returns

      text(t,x,labels,'FontWeight','bold','FontSize',9);

    endfunction

    function [] = DoVolatility(this)

      rts = [this.returns.rateOfReturn];
      vol = std(rts); % standard deviation = volatility
      num = numel(rts);
      tvals=arrayfun(@(s) this.GetDayNumber(s),[this.returns(:).year]);

      hold on;
      plot(tvals,(0+vol)*ones(num,1),'r--');
      plot(tvals,(0-vol)*ones(num,1),'r--');
      hold off;
    endfunction

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

    function [r] = GetDate(this,daynr)
      i = find( this.timestamp == daynr );
      r = datestr(this.timestamp(i));
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

    function [r,fmt] = GetTimeTicks(this)
      % gets xticks and date format depending on timestep
      numReturns = numel([this.returns.rateOfReturn]);
      switch this.timestep
        case 'day'
          dt = 10;
          fmt = 'YY-mm-dd';
          szfmt = 8;
        case 'week'
          dt = 10;
          fmt = 'YY-mm-dd';
          szfmt = 8;
          r = this.CalcYtdWeek();
        case 'month'
          dt = 10;
          fmt = 'YY-mm';
          szfmt = 6;
          r = this.CalcYtdMonth();
        case 'quarter'
          dt = 10;
          fmt = 'YY-mm';
          szfmt = 6;
          r = this.CalcYtdQuarter();
        otherwise
      endswitch
      r = [this.A(1:dt:numReturns,2)]; % 2 = lastDay
      % if there is enough room (szfmt), add the last return to the ticks,
      % otherwise replace the last tick with the last return.
      if this.A(numReturns,2) - r(end) > szfmt
        r(end+1) = this.A(numReturns,2);
      else
        r(end) = this.A(numReturns,2);
      endif
    endfunction

    function [r] = SetTimeStep(this,timestamp)
        dt = diff(timestamp);
        dd = mean(dt); % delta (in) days
        if dd >= 1 && dd <=2
          r = 'day';
        elseif dd >= 6 && dd <= 7
          r = 'week';
        elseif dd >= 27 && dd <= 31
          r = 'month';
        elseif dd >= 89 && dd <= 91
          r = 'quarter';
        else
          r = 'undefined';
        endif
    endfunction

    function [] = SetDayYrMatrix(this,yr)

      i1 = find(this.timestamp >= datenum(yr,1,1), 1, 'first');
      i2 = find(this.timestamp <= datenum(yr,12,31), 1, 'last');

      n = i2-i1+1;
      this.A = NaN(n+1,2); % 1 extra day to calculate return
      this.A(1,1) = this.timestamp(i1)-1; % -1 is the extra day
      this.A(2:end,1) = this.timestamp(i1:i2);
      this.A(:,2) = this.A(:,1)+1;
    endfunction

    function [] = SetWeekYrMatrix(this,yr)
      nrWeeksInYr = 52;
      nrDaysInWeek = 7;
      dnStart = datenum(yr,1,1);
      this.A = NaN(52,2);
      for i=1:nrWeeksInYr
        if i==1
          this.A(i,1) = dnStart;
        else
          this.A(i,1) = addtodate(dnStart, (i-1)*nrDaysInWeek,'days');
        endif
        this.A(i,2) = this.A(i,1) + (nrDaysInWeek-1);
      endfor
    endfunction

    function [] = SetMonthYrMatrix(this,yr)
      this.A = NaN(12,2);
      this.A(1,1) = datenum(strcat(num2str(yr), '-01-01'),'yyyy-mm-dd');
      this.A(1,2) = datenum(strcat(num2str(yr), '-01-31'),'yyyy-mm-dd');
      if is_leap_year(yr)
        this.A(2,1) = datenum(strcat(num2str(yr), '-02-01'),'yyyy-mm-dd');
        this.A(2,2) = datenum(strcat(num2str(yr), '-02-29'),'yyyy-mm-dd');
      else
        this.A(2,1) = datenum(strcat(num2str(yr), '-02-01'),'yyyy-mm-dd');
        this.A(2,2) = datenum(strcat(num2str(yr), '-02-28'),'yyyy-mm-dd');
      endif
      this.A(3,1) = datenum(strcat(num2str(yr), '-03-01'),'yyyy-mm-dd');
      this.A(3,2) = datenum(strcat(num2str(yr), '-03-31'),'yyyy-mm-dd');
      this.A(4,1) = datenum(strcat(num2str(yr), '-04-01'),'yyyy-mm-dd');
      this.A(4,2) = datenum(strcat(num2str(yr), '-04-30'),'yyyy-mm-dd');
      this.A(5,1) = datenum(strcat(num2str(yr), '-05-01'),'yyyy-mm-dd');
      this.A(5,2) = datenum(strcat(num2str(yr), '-05-31'),'yyyy-mm-dd');
      this.A(6,1) = datenum(strcat(num2str(yr), '-06-01'),'yyyy-mm-dd');
      this.A(6,2) = datenum(strcat(num2str(yr), '-06-30'),'yyyy-mm-dd');
      this.A(7,1) = datenum(strcat(num2str(yr), '-07-01'),'yyyy-mm-dd');
      this.A(7,2) = datenum(strcat(num2str(yr), '-07-31'),'yyyy-mm-dd');
      this.A(8,1) = datenum(strcat(num2str(yr), '-08-01'),'yyyy-mm-dd');
      this.A(8,2) = datenum(strcat(num2str(yr), '-08-31'),'yyyy-mm-dd');
      this.A(9,1) = datenum(strcat(num2str(yr), '-09-01'),'yyyy-mm-dd');
      this.A(9,2) = datenum(strcat(num2str(yr), '-09-30'),'yyyy-mm-dd');
      this.A(10,1) = datenum(strcat(num2str(yr), '-10-01'),'yyyy-mm-dd');
      this.A(10,2) = datenum(strcat(num2str(yr), '-10-31'),'yyyy-mm-dd');
      this.A(11,1) = datenum(strcat(num2str(yr), '-11-01'),'yyyy-mm-dd');
      this.A(11,2) = datenum(strcat(num2str(yr), '-11-30'),'yyyy-mm-dd');
      this.A(12,1) = datenum(strcat(num2str(yr), '-12-01'),'yyyy-mm-dd');
      this.A(12,2) = datenum(strcat(num2str(yr), '-12-31'),'yyyy-mm-dd');
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
