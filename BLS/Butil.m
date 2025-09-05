classdef Butil < handle
  % utilities for BLS folder
  % https://www.mathworks.com/matlabcentral/answers/182131-percentile-of-a-value-based-on-array-of-data

  properties (Constant)
    MinLengthReturns = 3;
    MaxNumXTicks = 8;
    YLabelFontSize = 14;
    TitleFontSize = 16;
    LegendFontSize = 12;
    PlotMarkerSize = 10;
    PlotLineWidth = 1.0;
  endproperties

  methods (Static = true) % Public

    function [r] = CalcPercentile(data,value)
      data = data(:)';
      value = value(:);

      nless = sum(data < value, 2);
      nequal = sum(data == value, 2);
      r = 100*( (nless + 0.5.*nequal) / length(data) );
    endfunction

    function [p,e_var,r,p_var,fit_var] = DoLinearRegression(x,y)
      % https://octave.sourceforge.io/optim/function/LinearRegression.html
      pkg load optim;

    endfunction

    function [r] = GetAPR(t,y)
      timestep = Butil.GetTimeStep(t);
      r = mean(y);
      switch timestep
        case 'day'
          r = r*(365);
        case 'week'
          r = r*(52);
        case 'month'
          r = r*(12);
        case 'quarter'
          r = r*(4);
        otherwise
      endswitch
    endfunction

    function [r] = GetDateNum(this,y)
      yearStr = num2str(y);
      dateStr = strcat(yearStr,'-01-01');
      r = datenum(dateStr,'yyyy-mm-dd');
    endfunction

    function [r] = GetDateStr(this,daynr)
      i = find( this.timestamp == daynr );
      r = datestr(this.timestamp(i));
    endfunction

    function [r] = GetDateToday()
      r = datestr(now(),'yyyy-mm-dd');
    endfunction

    function [r] = GetDayToday()
      s = Butil.GetDateToday();
      r = datenum(s,'yyyy-mm-dd');
    endfunction

    function [r] = GetDay(date)
      y = str2num(datestr(date,'yyyy'));
      m = str2num(datestr(date,'mm'));
      d = str2num(datestr(date,'dd'));
      r = datenum(y,m,d);
    endfunction

    function [r,fmt] = GetDateTicks(t)
      % gets xticks and date format depending on timestep
      timestep = Butil.GetTimeStep(t);
      switch timestep
        case 'day'
          dt = 15;
          fmt = 'YY-mm-dd';
          szfmt = 8;
        case 'week'
          dt = 10;
          fmt = 'YY-mm-dd';
          szfmt = 8;
        case 'month'
          dt = 10;
          fmt = 'YY-mm';
          szfmt = 6;
        case 'quarter'
          dt = 10;
          fmt = 'YY-mm';
          szfmt = 6;
        otherwise
          error('invalid number timestep: %s. \n',timestep);
      endswitch
      if length(t) > Butil.MaxNumXTicks
        r = t(1:dt:end);
      else
        r = t(1:1:end);
      endif
      % if there is enough room (szfmt), add the last return to the ticks,
      % otherwise replace the last tick with the last return.
      if t(end) - r(end) > szfmt
        r(end+1) = t(end);
      else
        r(end) = t(end);
      endif
    endfunction

    function [r] = GetTimeStep(timestamp)

        if length(timestamp) < 2
          error('invalid number of timestamps: %d. \n',length(timestamp));
        endif

        dt = diff(timestamp);
        dd = mean(dt); % delta (in) days
        if dd >= 1 && dd <=2
          r = 'day';
        elseif dd >= 6 && dd <= 7
          r = 'week';
        elseif dd >= 27 && dd <= 31
          r = 'month';
        elseif dd >= 89 && dd <= 92
          r = 'quarter';
        else
          error('invalid delta timestamp: %.2f. \n',dd);
        endif
    endfunction

    function [r] = RemoveTrend(x)
      r = diff(x);
    endfunction

    function [r] = Round(r)
      r = round(r.*100)./100; % round to nearest 2 decimal places
    endfunction

  endmethods
endclassdef
