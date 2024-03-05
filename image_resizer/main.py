import boto3
import os
from PIL import Image
import io
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')

# Prepare the logger
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def resize_image(image_path, output_size):
    with Image.open(image_path) as img:
        img.thumbnail(output_size)
        buffer = io.BytesIO()
        img.save(buffer, 'JPEG')
        buffer.seek(0)
        return buffer



def ensure_directories_exist(file_path):
    os.makedirs(os.path.dirname(file_path), exist_ok=True)


def lambda_handler(event, context):
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        filename = os.path.basename(key)

        # Ignore non-image files
        if not filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            continue

        download_path = f'/tmp/{filename}'
        s3_client.download_file(source_bucket, key, download_path)

        # Define desired sizes including 'original' to simply move without resizing
        sizes = {
            'xx-large': (4096, 4096),
            'x-large': (1440, 1440),
            'large': (1920, 1920),
            'medium': (512, 512),
            'thumbnail': (256, 256),
            'original': None  # No resizing for the original
        }

        # Process and upload images
        for size_name, dimensions in sizes.items():
            logger.info(f'Processing {size_name} image')
            if dimensions:
                resized_image = resize_image(download_path, dimensions)
                logger.debug(f'Resized {size_name} image')
            else:
                # Open the original for 'original' size without resizing
                resized_image = open(download_path, 'rb')
                logger.debug(f'Opened original image')

            upload_key = f'static/images/{os.path.splitext(filename)[0]}/{size_name}.jpg'
            target_bucket = source_bucket  # or specify a different target bucket

            # Upload the image variant
            s3_client.upload_fileobj(resized_image, target_bucket, upload_key, ExtraArgs={'ContentType': 'image/jpeg'})
            logger.info(f'Uploaded {size_name} image to {upload_key}')

            # Close the file if opened directly without resizing
            if size_name == 'original':
                resized_image.close()

        # Remove the original file from the uploads directory
        s3_client.delete_object(Bucket=source_bucket, Key=key)


# Run the lambda_handler function when the Lambda function is invoked
if __name__ == '__main__':
    # Print AWS S3 bucket name
    print(os.getenv('S3_BUCKET'))
    event = {
        'Records': [
            {
                's3': {
                    'bucket': {
                        'name': 'snapfleet-thumbnail-bucket'
                    },
                    'object': {
                        'key': 'static/uploads/_D3C3771.jpg'
                    }
                }
            }
        ]
    }
    lambda_handler(event, None)
