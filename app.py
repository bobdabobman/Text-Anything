import os
import logging
from flask import Flask, request, abort
from twilio.twiml.messaging_response import MessagingResponse
from twilio.request_validator import RequestValidator

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

messages = []

# Twilio credentials
TWILIO_AUTH_TOKEN = os.environ.get('TWILIO_AUTH_TOKEN')

@app.route('/sms', methods=['POST'])
def sms_reply():
    # Validate incoming request from Twilio
    validator = RequestValidator(TWILIO_AUTH_TOKEN)
    url = request.url
    post_vars = request.form.to_dict()
    signature = request.headers.get('X-Twilio-Signature', '')

    if not validator.validate(url, post_vars, signature):
        logger.warning('Unauthorized request to /sms endpoint')
        abort(403)

    msg_body = post_vars.get('Body')
    messages.append(msg_body)
    logger.info(f'Received SMS message: {msg_body}')

    resp = MessagingResponse()
    resp.message("Message received. Thank you!")

    return str(resp)

@app.route('/')
def hello_world():
    html = '<h1>hello world</h1>'
    if messages:
        html += '<h2>Received Messages:</h2><ul>'
        for msg in messages:
            html += f'<li>{msg}</li>'
        html += '</ul>'
    return html

if __name__ == '__main__':
    # Use a production-ready server (e.g., Gunicorn) in production environments
    app.run(host='0.0.0.0', port=5000)
