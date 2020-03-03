library(tseries)
library(forecast)
library(lmtest)


getwd()

data=read.csv('global.txt',sep="\t",header=TRUE)

time_a = ts(data,start = 1856, frequency=12)
time_b = decompose(time_a)
trend_data = data.frame(trendd = c(time_b$trendd), time = c(time(time_b$trendd)))

reg = lm(trend_data$trend ~ trend_data$time)
summary(reg)
#The results indicate a significant relationship between the trendd and time 
#This is indicative of non-stationarity, but not conclusive

#Comparing means of trendd-model to non-trendd-model

trend = time_a - time_b$seasonal
mean(trend)
var(trend)

random_a = time_a - time_b$seasonal - time_b$trend
mean(na.omit(random_a))
var(na.omit(random_a))
#The trendd component does increase both the mean and variance

#Augmented Dickey-Fuller (ADF) t-test
adf.test(trend, k = 20, alternative = "stationary")
#The p-value of the ADF test is significant
#This indicates the time series is stationary

#Kwiatkowski-Phillips-Schmidt-Shin (KPSS) test
kpss.test(trend)
#The test here is significant indicating the time series data is non-stationary

#Now that we know we have a non-stationary data, We need to idenitfy the lag
acf(time_a)
acf(trend, lag.max = 20)


difference1 = diff(trend, differences=1)
plot(difference1)

adf.test(difference1, k = 20, alternative = "stationary")
kpss.test(difference1)

acf(difference1)
pacf(difference1)

#Based on these rules of thumb and the ACF and PACF, the following possibilities exist:
#ARMA(1, 1): The correlogram “dies down” while the partial correlogram also dies down with multiple effects
#ARMA(2, 0): Since the partial correlogram dies off dramatically after the first two lags, then the effects can be attributed to autocorrelation effects
#ARMA(2, 1): A combination of the two previous models, which may also include an ARMA(3, 1) model

mod_a = arima(difference1, order = c(1, 0, 1), method = "ML")
mod_b = arima(difference1, order = c(2, 0, 0), method = "ML")
mod_c = arima(difference1, order = c(2, 0, 1), method = "ML")

#Estimation of Components
coeftest(mod_a)
coeftest(mod_b)
coeftest(mod_c)

#Diagnostic Checking
mod_b_a = AIC(mod_a, k = log(length(difference1)))
mod_b_b = AIC(mod_b, k = log(length(difference1)))
mod_b_c = AIC(mod_c, k = log(length(difference1)))

#Forecast
mod_f_a = forecast(mod_a, h = 20)
mod_f_b = forecast(mod_b, h = 20)
mod_f_c = forecast(mod_c, h = 20)

plot(mod_f_a)
plot(mod_f_b)
plot(mod_f_c)

accuracy(mod_f_a)
accuracy(mod_f_b)
accuracy(mod_f_c)
