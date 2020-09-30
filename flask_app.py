#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
from flask import Flask, request, jsonify
from Caption_generation import get_caption

app = Flask(__name__)

@app.route('/caption', methods=['POST'])
def image_caption():
    if request.method == 'POST':
        file_name = request.files['file']
        path = './static/' + file_name.filename
        file_name.save(path)
        caption = get_caption(path)
        os.remove(path)
        return jsonify(caption)

if __name__ == '__main__':
    app.run(debug=True)
