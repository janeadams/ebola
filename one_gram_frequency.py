#!/usr/bin/env python
# coding: utf-8
"""
Created on Mon Feb 10 14:25:58 2020

One gram frequency time series build and plotting script function library!


@author: max
"""



import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.feature_extraction.text import CountVectorizer
import datetime
from collections import Counter
import nltk
from sklearn.linear_model import LinearRegression

from scipy import stats

#nltk.download()

def build_corpus(reports, variable_name):
    """
    Description:
        Build list of list of bag of words for a given variable from a data frame
    Input:
        reports : data frame holding all variables
        variable_name : column name of variable of interest
    Output : 
            time_corpus : list of lists of bag of words per time period
    """    
    # Produce time series of word frequencies in desired column
    
    time_data = reports[['g_mob_activities/date_of_visit',variable_name]]
    
    time_data_full = time_data.dropna()
    
    # investigate date range
    Counter(list(time_data_full['g_mob_activities/date_of_visit']))
    datetime.datetime.strptime('6/16/2006',"%m/%d/%Y")
    # reformat dates as datetimes
    dates= list(time_data_full['g_mob_activities/date_of_visit'])
    dates_formated = [datetime.datetime.strptime(date,"%m/%d/%Y") for date in dates] 
    time_data_full['date_f'] = dates_formated
    
    # filter data frame to only remove all dates outside of peak outbreak
    upper = time_data_full[time_data_full['date_f'] > datetime.datetime(2014,11,20)];
    peak = upper[time_data_full['date_f'] < datetime.datetime(2015,12,20)];
    
    # tokenize text in column of interest
    peak['tokenized_sents'] = peak.apply(lambda row: nltk.word_tokenize(row[variable_name]), axis=1);
    
    
    peak['month'] = peak['date_f'].apply(lambda row :row.month)
    peak['year'] = peak['date_f'].apply(lambda row : row.year)
    
    
    # the plot in the paper include the two months of 2014
    # however, I am finding that these months often contain zero counts
    time_corpus = [[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
    months = [11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2]
    years = [2014,2014,2015,2015,2015,2015,2015,2015,2015,2015,2015,2015,2015,2015]
    
    
    # build time corpus data structure
    for idx in range(0,14):
        
        row = peak[peak['month'] == months[idx]]
        row = row[row['year'] == years[idx]]
     
        row_corpus = list(row['tokenized_sents'])
        full_corpus = []
        for entry in row_corpus:
            for word in entry:
                full_corpus.append(word.lower())
                
        time_corpus[idx].extend(full_corpus)

        
    return(time_corpus)
    
    

def build_timeseries(woi,time_corpus):
    """
    Description:
        Caculate a timeseries of the word frequency over a month to month basis. 
    Input : 
        woi : word of interest
        time_corpus : list of lists of bag of words per time period
    Return :
        time_corpus_counter : list of Counter dictionaries per time period
    
    
    """
    time_corpus_counter = []
    for corpus in time_corpus:
        
        corpus_counter = Counter(corpus)
        woi_counts = corpus_counter[woi]

        rel_counts = woi_counts/len(corpus)
        if rel_counts != 0:
            time_corpus_counter.append(rel_counts)
    return(time_corpus_counter)
    
def plot_timeseries(time_corpus_counter,woi, text_column):
    """
    Description:
        plot timeseries present in time_corpus_counter for word of interest (woi). Overlay the results of a linear regression.
    Input:
        time_corpus_counter : list of dictionaries of one-gram counts per time period
        woi : word of interest
        tet_column : name of variable
    Output:
        the requested plot
    """    
    x = list(range(len(time_corpus_counter)))
    
    slope, intercept, r_value, p_value, std_err = stats.linregress(x,time_corpus_counter)

    
    y_pred = np.array(x)*slope+intercept
    
    slope = np.round(slope, decimals = 2)
    intercept = np.round(intercept, decimals = 2)
    r_value = np.round(r_value, decimals = 2)
    p_value = np.round(p_value, decimals = 2)
    fig,ax = plt.subplots(figsize = (10,8))
    ax.scatter(x,time_corpus_counter)
    ax.plot(x, y_pred,'b',label = str(slope) + ", p = {} ".format(p_value) + " r = {}".format(r_value) )
    plt.ylabel("Relative Frequency of Word")
    plt.xlabel("Date")
    plt.legend(loc = 'upper-left')
    plt.title('Relative Use of {}'.format(woi) + ' in  {}'.format(text_column))
    ax.set_xticks(list(range(0,12,2)))
    ax.set_xticklabels(timeseries_x,rotation= 45)
    plt.show()




# load in file
if __name__ == '__main__':

    # load in data
    reports = pd.read_csv('8247002/digital.csv')
    
    # define name of column of interest
    text_column = 'g_actionstat/action1'
    
    # define the dates for time series
    timeseries_x = ['2015-01-31', '2015-03-31', '2015-05-30',  '2015-07-30','2015-09-31', '2015-11-31']
    
    
    # build corpus from column data
    time_corpus = build_corpus(reports, text_column)
    
    
    # Example time series plots
    woi = 'dead'
    counts = build_timeseries(woi,time_corpus)
    plot_timeseries(counts, woi,text_column)
    
    woi = 'meat'
    counts = build_timeseries(woi,time_corpus)
    plot_timeseries(counts, woi,text_column)
    
    
    woi = 'bush'
    counts = build_timeseries(woi,time_corpus)
    plot_timeseries(counts, woi,text_column)
    

    
    
