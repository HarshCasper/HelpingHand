# Currency Detection

Our application allows user to detect currency notes as well.

We have used a custom trained tflite model trained on Indian currency. This model can be trained on more data to detect currencies of other countries as well.

## Workflow of the currency detection system

- Open the currency detection screen and tap on it.
- Click a photo of the note. Our model can classify low quality or blurred images, or folded notes as well with high accuracy.
- The model will classify the image, show a dialog along with the prediction. For better accessibility, our text-to-speech functionality will also speak out the prediction made so the user does not need to actually see the screen for the prediction made.

## Example

| ![1](https://user-images.githubusercontent.com/41234408/94897157-b2779700-04ac-11eb-8fdc-4556b87206e7.png)  | ![2](https://user-images.githubusercontent.com/41234408/94897180-bb686880-04ac-11eb-8657-40aa1f360765.png)  | ![3](https://user-images.githubusercontent.com/41234408/94897200-c3280d00-04ac-11eb-8f0a-9daf8d1cf15b.png)  |
|---|---|---|
| Taking a picture  | Prediction for a blurred 500INR Note  | Prediction for a 20INR Note  |
