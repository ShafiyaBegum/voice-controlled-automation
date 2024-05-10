from urllib import request


@app.route('/process_voice_input', methods=['POST']) # type: ignore

def process_voice_input():
    print("started")
    data = request.json
    print(data)
    voice_input = data.get('voiceInput')
    processed_data = voice_input.upper()
    print(processed_data)
    return jsonify({'processedData': processed_data}) # type: ignore