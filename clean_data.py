from sklearn.feature_extraction.text import CountVectorizer


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
    
    X = model.fit_transform(corpus)
    bag = model.get_feature_names()
    counts = X.toarray()
    
    return bag, counts
    
corpus = ["Don't eat my sandwich",
          "HELLO,, there",
          "Data Lab is cool!"]

print(bag_of_words(corpus))

with open('data/Follow_Up_Other.csv', 'r') as f:
    for line in f:
        pass
    
with open('data/Trigger_Other.csv', 'r') as f:
    for line in f:
        pass
    


