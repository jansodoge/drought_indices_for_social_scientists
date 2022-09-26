# Soil moisture for social science
R code to use the UFZ soil moisture index and drought intensity measures for social scientists


The goal of this repository is providing an intutive way to work with soil moisture data - a bio-physical measure for drought. We provide tools to customize this drought measure for desired spatial and temporal scopes.



__What data do we use__


We employ data provided by the drought monitor from the Helmholtz Centre for Environmental research (https://www.ufz.de/index.php?en=37937). Here, the soil moisture index reflects the measurement of drought that we apply for the following tool and analyses.


__How 'area under drought' is calculated__

Using the soil moisture index (SMI), we calculate the area under drought as follows:
For each statistical unit (here NUT units), we count the number of measurements
within the selected timeframe below a specified threshold (0.2 following Samaniego et al (2013)). These are the observations where there is a drought (given the threshold). Then, we divide this by the total number of observations in the timeframe. The resulting share is equivalent to the average area under drought.
