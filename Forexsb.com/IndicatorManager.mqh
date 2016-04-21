//+--------------------------------------------------------------------+
//| Copyright:  (C) 2016 Forex Software Ltd.                           |
//| Website:    http://forexsb.com/                                    |
//| Support:    http://forexsb.com/forum/                              |
//| License:    Proprietary under the following circumstances:         |
//|                                                                    |
//| This code is a part of Forex Strategy Builder. It is free for      |
//| use as an integral part of Forex Strategy Builder.                 |
//| One can modify it in order to improve the code or to fit it for    |
//| personal use. This code or any part of it cannot be used in        |
//| other applications without a permission.                           |
//| The contact information cannot be changed.                         |
//|                                                                    |
//| NO LIABILITY FOR CONSEQUENTIAL DAMAGES                             |
//|                                                                    |
//| In no event shall the author be liable for any damages whatsoever  |
//| (including, without limitation, incidental, direct, indirect and   |
//| consequential damages, damages for loss of business profits,       |
//| business interruption, loss of business information, or other      |
//| pecuniary loss) arising out of the use or inability to use this    |
//| product, even if advised of the possibility of such damages.       |
//+--------------------------------------------------------------------+

#property copyright "Copyright (C) 2016 Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "3.00"
#property strict

#include <Forexsb.com\Indicators\AcceleratorOscillator.mqh>
#include <Forexsb.com\Indicators\AccountPercentStop.mqh>
#include <Forexsb.com\Indicators\AccumulationDistribution.mqh>
#include <Forexsb.com\Indicators\ADX.mqh>
#include <Forexsb.com\Indicators\Alligator.mqh>
#include <Forexsb.com\Indicators\AroonHistogram.mqh>
#include <Forexsb.com\Indicators\ATRMAOscillator.mqh>
#include <Forexsb.com\Indicators\ATRStop.mqh>
#include <Forexsb.com\Indicators\AverageTrueRange.mqh>
#include <Forexsb.com\Indicators\AwesomeOscillator.mqh>
#include <Forexsb.com\Indicators\BalanceofPower.mqh>
#include <Forexsb.com\Indicators\BarClosing.mqh>
#include <Forexsb.com\Indicators\BarOpening.mqh>
#include <Forexsb.com\Indicators\BarRange.mqh>
#include <Forexsb.com\Indicators\BBPMAOscillator.mqh>
#include <Forexsb.com\Indicators\BearsPower.mqh>
#include <Forexsb.com\Indicators\BollingerBands.mqh>
#include <Forexsb.com\Indicators\BullsBearsPower.mqh>
#include <Forexsb.com\Indicators\BullsPower.mqh>
#include <Forexsb.com\Indicators\CCIMAOscillator.mqh>
#include <Forexsb.com\Indicators\CloseAndReverse.mqh>
#include <Forexsb.com\Indicators\CommodityChannelIndex.mqh>
#include <Forexsb.com\Indicators\CumulativeSum.mqh>
#include <Forexsb.com\Indicators\DayClosing.mqh>
#include <Forexsb.com\Indicators\DayClosing2.mqh>
#include <Forexsb.com\Indicators\DaysOfWeek.mqh>
#include <Forexsb.com\Indicators\DayOpening.mqh>
#include <Forexsb.com\Indicators\DeMarker.mqh>
#include <Forexsb.com\Indicators\DetrendedOscillator.mqh>
#include <Forexsb.com\Indicators\DirectionalIndicators.mqh>
#include <Forexsb.com\Indicators\DonchianChannel.mqh>
#include <Forexsb.com\Indicators\EaseofMovement.mqh>
#include <Forexsb.com\Indicators\EnterOnce.mqh>
#include <Forexsb.com\Indicators\EntryHour.mqh>
#include <Forexsb.com\Indicators\EntryTime.mqh>
#include <Forexsb.com\Indicators\Envelopes.mqh>
#include <Forexsb.com\Indicators\ExitHour.mqh>
#include <Forexsb.com\Indicators\FisherTransform.mqh>
#include <Forexsb.com\Indicators\ForceIndex.mqh>
#include <Forexsb.com\Indicators\Fractal.mqh>
#include <Forexsb.com\Indicators\HeikenAshi.mqh>
#include <Forexsb.com\Indicators\HourlyHighLow.mqh>
#include <Forexsb.com\Indicators\IchimokuKinkoHyo.mqh>
#include <Forexsb.com\Indicators\InsideBar.mqh>
#include <Forexsb.com\Indicators\KeltnerChannel.mqh>
#include <Forexsb.com\Indicators\LongOrShort.mqh>
#include <Forexsb.com\Indicators\MAOscillator.mqh>
#include <Forexsb.com\Indicators\MACD.mqh>
#include <Forexsb.com\Indicators\MACDHistogram.mqh>
#include <Forexsb.com\Indicators\MarketFacilitationIndex.mqh>
#include <Forexsb.com\Indicators\Momentum.mqh>
#include <Forexsb.com\Indicators\MomentumMAOscillator.mqh>
#include <Forexsb.com\Indicators\MoneyFlow.mqh>
#include <Forexsb.com\Indicators\MoneyFlowIndex.mqh>
#include <Forexsb.com\Indicators\MovingAvrg.mqh>
#include <Forexsb.com\Indicators\MovingAveragesCrossover.mqh>
#include <Forexsb.com\Indicators\NBarsExit.mqh>
#include <Forexsb.com\Indicators\NarrowRange.mqh>
#include <Forexsb.com\Indicators\OBOSMAOscillator.mqh>
#include <Forexsb.com\Indicators\OnBalanceVolume.mqh>
#include <Forexsb.com\Indicators\OscillatorofATR.mqh>
#include <Forexsb.com\Indicators\OscillatorofBBP.mqh>
#include <Forexsb.com\Indicators\OscillatorofCCI.mqh>
#include <Forexsb.com\Indicators\OscillatorofMACD.mqh>
#include <Forexsb.com\Indicators\OscillatorofMomentum.mqh>
#include <Forexsb.com\Indicators\OscillatorofOBOS.mqh>
#include <Forexsb.com\Indicators\OscillatorofROC.mqh>
#include <Forexsb.com\Indicators\OscillatorofRSI.mqh>
#include <Forexsb.com\Indicators\OscillatorofTrix.mqh>
#include <Forexsb.com\Indicators\OverboughtOversoldIndex.mqh>
#include <Forexsb.com\Indicators\ParabolicSAR.mqh>
#include <Forexsb.com\Indicators\PercentChange.mqh>
#include <Forexsb.com\Indicators\PivotPoints.mqh>
#include <Forexsb.com\Indicators\PreviousBarClosing.mqh>
#include <Forexsb.com\Indicators\PreviousBarOpening.mqh>
#include <Forexsb.com\Indicators\PreviousHighLow.mqh>
#include <Forexsb.com\Indicators\PriceMove.mqh>
#include <Forexsb.com\Indicators\PriceOscillator.mqh>
#include <Forexsb.com\Indicators\RateofChange.mqh>
#include <Forexsb.com\Indicators\RelativeVigorIndex.mqh>
#include <Forexsb.com\Indicators\ROCMAOscillator.mqh>
#include <Forexsb.com\Indicators\RossHook.mqh>
#include <Forexsb.com\Indicators\RoundNumber.mqh>
#include <Forexsb.com\Indicators\RSI.mqh>
#include <Forexsb.com\Indicators\RSIMAOscillator.mqh>
#include <Forexsb.com\Indicators\StandardDeviation.mqh>
#include <Forexsb.com\Indicators\StarcBands.mqh>
#include <Forexsb.com\Indicators\SteadyBands.mqh>
#include <Forexsb.com\Indicators\Stochastics.mqh>
#include <Forexsb.com\Indicators\StopLimit.mqh>
#include <Forexsb.com\Indicators\StopLoss.mqh>
#include <Forexsb.com\Indicators\TakeProfit.mqh>
#include <Forexsb.com\Indicators\TopBottomPrice.mqh>
#include <Forexsb.com\Indicators\TrailingStop.mqh>
#include <Forexsb.com\Indicators\TrailingStopLimit.mqh>
#include <Forexsb.com\Indicators\TrixIndex.mqh>
#include <Forexsb.com\Indicators\TrixMAOscillator.mqh>
#include <Forexsb.com\Indicators\WeekClosing.mqh>
#include <Forexsb.com\Indicators\WeekClosing2.mqh>
#include <Forexsb.com\Indicators\WilliamsPercentRange.mqh>

//## Import Start

class IndicatorManager
{
public:
   Indicator        *CreateIndicator(string indicatorName,SlotTypes slotType);
};

Indicator *IndicatorManager::CreateIndicator(string indicatorName,SlotTypes slotType)
{
   if(indicatorName == "Accelerator Oscillator")    return new AcceleratorOscillator(slotType);
   if(indicatorName == "Account Percent Stop")      return new AccountPercentStop(slotType);
   if(indicatorName == "Accumulation Distribution") return new AccumulationDistribution(slotType);
   if(indicatorName == "ADX")                       return new ADX(slotType);
   if(indicatorName == "Alligator")                 return new Alligator(slotType);
   if(indicatorName == "Aroon Histogram")           return new AroonHistogram(slotType);
   if(indicatorName == "ATR MA Oscillator")         return new ATRMAOscillator(slotType);
   if(indicatorName == "ATR Stop")                  return new ATRStop(slotType);
   if(indicatorName == "Average True Range")        return new AverageTrueRange(slotType);
   if(indicatorName == "Awesome Oscillator")        return new AwesomeOscillator(slotType);
   if(indicatorName == "Balance of Power")          return new BalanceofPower(slotType);
   if(indicatorName == "Bar Closing")               return new BarClosing(slotType);
   if(indicatorName == "Bar Opening")               return new BarOpening(slotType);
   if(indicatorName == "Bar Range")                 return new BarRange(slotType);
   if(indicatorName == "BBP MA Oscillator")         return new BBPMAOscillator(slotType);
   if(indicatorName == "Bears Power")               return new BearsPower(slotType);
   if(indicatorName == "Bollinger Bands")           return new BollingerBands(slotType);
   if(indicatorName == "Bulls Bears Power")         return new BullsBearsPower(slotType);
   if(indicatorName == "Bulls Power")               return new BullsPower(slotType);
   if(indicatorName == "CCI MA Oscillator")         return new CCIMAOscillator(slotType);
   if(indicatorName == "Close and Reverse")         return new CloseAndReverse(slotType);
   if(indicatorName == "Commodity Channel Index")   return new CommodityChannelIndex(slotType);
   if(indicatorName == "Cumulative Sum")            return new CumulativeSum(slotType);
   if(indicatorName == "Day Closing")               return new DayClosing(slotType);
   if(indicatorName == "Day Closing 2")             return new DayClosing2(slotType);
   if(indicatorName == "Day of Week")               return new DaysOfWeek(slotType);
   if(indicatorName == "Day Opening")               return new DayOpening(slotType);
   if(indicatorName == "DeMarker")                  return new DeMarker(slotType);
   if(indicatorName == "Detrended Oscillator")      return new DetrendedOscillator(slotType);
   if(indicatorName == "Directional Indicators")    return new DirectionalIndicators(slotType);
   if(indicatorName == "Donchian Channel")          return new DonchianChannel(slotType);
   if(indicatorName == "Ease of Movement")          return new EaseofMovement(slotType);
   if(indicatorName == "Enter Once")                return new EnterOnce(slotType);
   if(indicatorName == "Entry Hour")                return new EntryHour(slotType);
   if(indicatorName == "Entry Time")                return new EntryTime(slotType);
   if(indicatorName == "Envelopes")                 return new Envelopes(slotType);
   if(indicatorName == "Exit Hour")                 return new ExitHour(slotType);
   if(indicatorName == "Fisher Transform")          return new FisherTransform(slotType);
   if(indicatorName == "Force Index")               return new ForceIndex(slotType);
   if(indicatorName == "Fractal")                   return new Fractal(slotType);
   if(indicatorName == "Heiken Ashi")               return new HeikenAshi(slotType);
   if(indicatorName == "Hourly High Low")           return new HourlyHighLow(slotType);
   if(indicatorName == "Ichimoku Kinko Hyo")        return new IchimokuKinkoHyo(slotType);
   if(indicatorName == "Inside Bar")                return new InsideBar(slotType);
   if(indicatorName == "Keltner Channel")           return new KeltnerChannel(slotType);
   if(indicatorName == "Long or Short")             return new LongOrShort(slotType);
   if(indicatorName == "MA Oscillator")             return new MAOscillator(slotType);
   if(indicatorName == "MACD")                      return new MACD(slotType);
   if(indicatorName == "MACD Histogram")            return new MACDHistogram(slotType);
   if(indicatorName == "Market Facilitation Index") return new MarketFacilitationIndex(slotType);
   if(indicatorName == "Momentum")                  return new Momentum(slotType);
   if(indicatorName == "Momentum MA Oscillator")    return new MomentumMAOscillator(slotType);
   if(indicatorName == "Money Flow")                return new MoneyFlow(slotType);
   if(indicatorName == "Money Flow Index")          return new MoneyFlowIndex(slotType);
   if(indicatorName == "Moving Average")            return new MovingAvrg(slotType);
   if(indicatorName == "Moving Averages Crossover") return new MovingAveragesCrossover(slotType);
   if(indicatorName == "N Bars Exit")               return new NBarsExit(slotType);
   if(indicatorName == "Narrow Range")              return new NarrowRange(slotType);
   if(indicatorName == "OBOS MA Oscillator")        return new OBOSMAOscillator(slotType);
   if(indicatorName == "On Balance Volume")         return new OnBalanceVolume(slotType);
   if(indicatorName == "Oscillator of ATR")         return new OscillatorofATR(slotType);
   if(indicatorName == "Oscillator of BBP")         return new OscillatorofBBP(slotType);
   if(indicatorName == "Oscillator of CCI")         return new OscillatorofCCI(slotType);
   if(indicatorName == "Oscillator of MACD")        return new OscillatorofMACD(slotType);
   if(indicatorName == "Oscillator of Momentum")    return new OscillatorofMomentum(slotType);
   if(indicatorName == "Oscillator of OBOS")        return new OscillatorofOBOS(slotType);
   if(indicatorName == "Oscillator of ROC")         return new OscillatorofROC(slotType);
   if(indicatorName == "Oscillator of RSI")         return new OscillatorofRSI(slotType);
   if(indicatorName == "Oscillator of Trix")        return new OscillatorofTrix(slotType);
   if(indicatorName == "Overbought Oversold Index") return new OverboughtOversoldIndex(slotType);
   if(indicatorName == "Parabolic SAR")             return new ParabolicSAR(slotType);
   if(indicatorName == "Percent Change")            return new PercentChange(slotType);
   if(indicatorName == "Pivot Points")              return new PivotPoints(slotType);
   if(indicatorName == "Previous Bar Closing")      return new PreviousBarClosing(slotType);
   if(indicatorName == "Previous Bar Opening")      return new PreviousBarOpening(slotType);
   if(indicatorName == "Previous High Low")         return new PreviousHighLow(slotType);
   if(indicatorName == "Price Move")                return new PriceMove(slotType);
   if(indicatorName == "Price Oscillator")          return new PriceOscillator(slotType);
   if(indicatorName == "Rate of Change")            return new RateofChange(slotType);
   if(indicatorName == "Relative Vigor Index")      return new RelativeVigorIndex(slotType);
   if(indicatorName == "ROC MA Oscillator")         return new ROCMAOscillator(slotType);
   if(indicatorName == "Ross Hook")                 return new RossHook(slotType);
   if(indicatorName == "Round Number")              return new RoundNumber(slotType);
   if(indicatorName == "RSI")                       return new RSI(slotType);
   if(indicatorName == "RSI MA Oscillator")         return new RSIMAOscillator(slotType);
   if(indicatorName == "Standard Deviation")        return new StandardDeviation(slotType);
   if(indicatorName == "Starc Bands")               return new StarcBands(slotType);
   if(indicatorName == "Steady Bands")              return new SteadyBands(slotType);
   if(indicatorName == "Stochastics")               return new Stochastics(slotType);
   if(indicatorName == "Stop Limit")                return new StopLimit(slotType);
   if(indicatorName == "Stop Loss")                 return new StopLoss(slotType);
   if(indicatorName == "Take Profit")               return new TakeProfit(slotType);
   if(indicatorName == "Top Bottom Price")          return new TopBottomPrice(slotType);
   if(indicatorName == "Trailing Stop")             return new TrailingStop(slotType);
   if(indicatorName == "Trailing Stop Limit")       return new TrailingStopLimit(slotType);
   if(indicatorName == "Trix Index")                return new TrixIndex(slotType);
   if(indicatorName == "Trix MA Oscillator")        return new TrixMAOscillator(slotType);
   if(indicatorName == "Week Closing")              return new WeekClosing(slotType);
   if(indicatorName == "Week Closing 2")            return new WeekClosing2(slotType);
   if(indicatorName == "Williams' Percent Range")   return new WilliamsPercentRange(slotType);
   //## Add Custom
   return NULL;
}

