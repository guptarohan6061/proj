library(tseries)
library(forecast)
library(lmtest)


getwd()

#importing data
data=read.csv('global.txt',sep="\t",header=TRUE)

time_a = ts(data,start = 1856, frequency=12)
time_b = decompose(time_a)
trend_data = data.frame(trendd = c(time_b$trendd), time = c(time(time_b$trendd)))

reg = lm(trend_data$trend ~ trend_data$time)
summary(reg)



#Comparing means
#Subjective Test
trend = time_a - time_b$seasonal
mean(trend)
var(trend)
random_a = time_a - time_b$seasonal - time_b$trend
mean(na.omit(random_a))
var(na.omit(random_a))


#Objective Test
#Augmented Dickey-Fuller -test
adf.test(trend, k = 20, alternative = "stationary")
#The p-value of the ADF test is significant
#This indicates the time series is stationary

#KPSS test
kpss.test(trend)


acf(time_a)
acf(trend, lag.max = 20)


difference1 = diff(trend, differences=1)
plot(difference1)

adf.test(difference1, k = 20, alternative = "stationary")
kpss.test(difference1)

acf(difference1)
pacf(difference1)


mod_a = arima(difference1, order = c(1, 0, 1), method = "ML")
mod_a
mod_b = arima(difference1, order = c(2, 0, 0), method = "ML")
mod_b
mod_c = arima(difference1, order = c(2, 0, 1), method = "ML")
mod_c

#Estimation of Components & Diagnostic Checking
coeftest(mod_a)
AIC(mod_a, k = log(length(difference1)))
coeftest(mod_b)
AIC(mod_b, k = log(length(difference1)))
coeftest(mod_c)
AIC(mod_c, k = log(length(difference1)))

#Diagnostic Checking
mod_b_a = AIC(mod_a, k = log(length(difference1)))
mod_b_b = AIC(mod_b, k = log(length(difference1)))
mod_b_c = AIC(mod_c, k = log(length(difference1)))

#Forecast
mod_f_a = forecast(mod_a, h = 20)
mod_f_b = forecast(mod_b, h = 20)
mod_f_c = forecast(mod_c, h = 20)

#plot & accuracy
accuracy(mod_f_a)
plot(mod_f_a)
accuracy(mod_f_b)
plot(mod_f_b)
accuracy(mod_f_c)
plot(mod_f_c)





