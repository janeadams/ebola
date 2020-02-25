from sklearn.feature_extraction.text import CountVectorizer

corpus = ["Don't eat my sandwich",
          "HELLO,, there",
          "Data Lab is cool!"]

model = CountVectorizer(lowercase=True)

X = model.fit_transform(corpus)
print(model.get_feature_names())
