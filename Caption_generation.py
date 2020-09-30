#!/usr/bin/python
# -*- coding: utf-8 -*-
import pickle
from keras.models import load_model
from keras.preprocessing import image
import numpy as np
from keras.applications.resnet50 import preprocess_input
from keras.preprocessing.sequence import pad_sequences

MAX_LENGTH = 40

new_model = load_model('models/image-captioning.h5')
new_model._make_predict_function()

Rmodel = load_model('models/pretrained-resnet.h5')
Rmodel._make_predict_function()

w2i_file = open('models/words-indices.p', 'rb')
words_to_indices2 = pickle.load(w2i_file)

i2w_file = open('models/indices-words.p', 'rb')
indices_to_words2 = pickle.load(i2w_file)

def get_enc(img_path):
    img = image.load_img(img_path, target_size=(224, 224))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    features = Rmodel.predict(x)
    photo = features.squeeze()
    return photo

def get_caption(img_path):
    enc = get_enc(img_path)
    caption = greedy_search(enc)
    return caption

def greedy_search(photo):
    photo = photo.reshape(1, 2048)
    in_text = '<start>'
    for i in range(MAX_LENGTH):
        sequence = [words_to_indices2[s] for s in in_text.split(' ')
                    if s in words_to_indices2]
        sequence = pad_sequences([sequence], maxlen=MAX_LENGTH,
                                 padding='post')
        y_pred = new_model.predict([photo, sequence], verbose=0)
        y_pred = np.argmax(y_pred[0])
        word = indices_to_words2[y_pred]
        in_text += ' ' + word
        if word == '<end>':
            break
    final_text = in_text.split()
    final_text = final_text[1:-1]
    final_text = ' '.join(final_text)
    return final_text


def beam_search2(photo, k):
    photo = photo.reshape(1, 2048)
    in_text = '<start>'
    sequence = [words_to_indices2[s] for s in in_text.split(' ') if s
                in words_to_indices2]
    sequence = pad_sequences([sequence], maxlen=MAX_LENGTH,
                             padding='post')
    y_pred = new_model.predict([photo, sequence], verbose=0)
    predicted = []
    y_pred = y_pred.reshape(-1)
    for i in range(y_pred.shape[0]):
        predicted.append((i, y_pred[i]))
    predicted = sorted(predicted, key=lambda x: x[1])[::-1]
    b_search = []
    for i in range(k):
        word = indices_to_words2[predicted[i][0]]
        b_search.append((in_text + ' ' + word, predicted[i][1]))

    for idx in range(MAX_LENGTH):
        b_search_square = []
        for text in b_search:
            if text[0].split(' ')[-1] == '<end>':
                break
            sequence = [words_to_indices2[s] for s in text[0].split(' '
                        ) if s in words_to_indices2]
            sequence = pad_sequences([sequence], maxlen=MAX_LENGTH,
                    padding='post')
            y_pred = new_model.predict([photo, sequence], verbose=0)
            predicted = []
            y_pred = y_pred.reshape(-1)
            for i in range(y_pred.shape[0]):
                predicted.append((i, y_pred[i]))
            predicted = sorted(predicted, key=lambda x: x[1])[::-1]
            for i in range(k):
                word = indices_to_words2[predicted[i][0]]
                b_search_square.append((text[0] + ' ' + word,
                        predicted[i][1] * text[1]))
        if len(b_search_square) > 0:
            b_search = (sorted(b_search_square, key=lambda x: x[1])[::
                        -1])[:5]
    final_text = b_search[0][0].split()
    final_text = final_text[1:-1]
    final_text = ' '.join(final_text)
    return final_text
