from sklearn.feature_extraction.text import CountVectorizer
import csv
import enchant
from gensim.corpora.dictionary import Dictionary

def bag_of_words(data):
    '''
    Runs the bag of words model on the given data
    
    Inputs
    ------
    data: list of strings
        data<=>corpus: the list is the corpus, and each string 
          is a document
    
    Returns
    -------
    list:
        list containing unique words of the corpus
    
    list of lists:
        list[documentID][wordID] returns the count for the word in the given
          document
    '''
    model = CountVectorizer(lowercase=True)
    
    X = model.fit_transform(data)
    bag = model.get_feature_names()
    counts = X.toarray()
    
    return bag, counts


def clean_questions(text):
    
    d = enchant.Dict("en_US")
    
    def f(x):
        if x.lower() == 'na':
            return 'NA'
        
        if d.check(x):
            return x
        
        try:
            new = d.suggest(x)[0]
            return new
        except:
            return x
        
    str = ''
    text = text.strip()
    for word in text.split():
        str += f(word) + ' '
        
    return str
    
    
#corpus = ["Don't eat my sandwich",
#          "HELLO,, there",
#          "Data Lab is cool!"]

#print(bag_of_words(corpus))

with open('data/Follow_Up_Other.csv') as csvFile:
    #0:     Date
    #1:     District
    #2:     Chiefdom
    #3:     Section
    #4:     community
    #5-10:  fq#
    
    d = enchant.Dict("en_US")
    
    reader = csv.reader(csvFile)
    questions = []
    for i, line in enumerate(reader):
        newLine = []
        if i != 0:
            for j,q in enumerate(line):
                if j > 4:
                    newLine.append(clean_questions(q))
                else:
                    newLine.append(q)
        else:
            newLine = line
            
        questions.append(newLine)


with open('data/Follow_Up_Other_CLEANED.csv', 'w') as csvFile:
    writer = csv.writer(csvFile)
    for row in questions:
        writer.writerow(row)
'''
with open('data/Trigger_Other.csv', 'r') as f:
    for line in f:
        pass
''' 


