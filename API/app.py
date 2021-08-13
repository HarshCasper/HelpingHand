from flask import Flask, request, jsonify
from captionbot import CaptionBot

app = Flask(__name__)

@app.route('/', methods = ['POST', 'GET'])
def home():
    return "This is the Home Endpoint"

@app.route('/caption', methods = ['POST'])
def caption():
    image_caption_result = ''
    if request.method == 'POST':
        image_url = request.form['image_url']
        image_caption_generator = CaptionBot()
        image_caption_result = jsonify(image_caption_generator.url_caption(str(image_url)))
        return image_caption_result

if __name__ == '__main__':
    app.run(debug=False)
