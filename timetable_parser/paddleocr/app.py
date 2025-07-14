from flask import Flask, request, jsonify
import os
from werkzeug.utils import secure_filename

# For actual OCR integration (PaddleOCR imports)
# from paddleocr import PaddleOCR  # Uncomment if you're using PaddleOCR directly

# Initialize Flask app
app = Flask(__name__)

# Set upload folder path
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Optionally limit file size (in bytes)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10 MB

# Allowed image types
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}

# Helper: Check if file is allowed
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Health check route
@app.route('/')
def home():
    return "✅ UniSync Timetable Parser is up and running!"

# Timetable parsing route
@app.route('/parse-timetable', methods=['POST'])
def parse_timetable():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file part'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # 🔽 OCR logic (pseudo or real)
        # ocr = PaddleOCR(use_angle_cls=True, lang='en')
        # result = ocr.ocr(filepath, cls=True)
        #
        # Parse result into structured timetable format here

        # For now, let's mock the OCR response:
        mock_response = {
            "rows": [
                {"time": "9:00", "subject": "Math", "teacher": "Dr. Sinha"},
                {"time": "10:00", "subject": "Physics", "teacher": "Prof. Iyer"},
                {"time": "11:00", "subject": "CS", "teacher": "Mr. Adil 😎"}
            ],
            "status": "success"
        }

        return jsonify(mock_response)

    return jsonify({'error': 'Invalid file type'}), 400

# Main entrypoint
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
