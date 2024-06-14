import logging
import json
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

        
    url = "https://www.onemap.gov.sg/api/public/themesvc/getThemeInfo?queryName=kindergartens"
        
    headers = {"Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjODEyOGU5YWFhMGUyMzNhYTQxZTU3ZjQ2ZmQ3MGVmMyIsImlzcyI6Imh0dHA6Ly9pbnRlcm5hbC1hbGItb20tcHJkZXppdC1pdC0xMjIzNjk4OTkyLmFwLXNvdXRoZWFzdC0xLmVsYi5hbWF6b25hd3MuY29tL2FwaS92Mi91c2VyL3Bhc3N3b3JkIiwiaWF0IjoxNzE3NDcxOTgwLCJleHAiOjE3MTc3MzExODAsIm5iZiI6MTcxNzQ3MTk4MCwianRpIjoiQ3JQU01jNmlGcGxGQUdyQyIsInVzZXJfaWQiOjEyMCwiZm9yZXZlciI6ZmFsc2V9.S-jurW6KeRYsbfMk-GPU6yhQuRZTjB7vdu9_vfF5-44"}
        
    res = requests.request("GET", url, headers=headers)
        

    logger.info('## Currency result: %s', res)
    response = {
        "statusCode": 200,
        "body": json.dumps(res.json()),
    }
    logger.info('## Response returned: %s', response)
    print(response)
    return response

# lambda_handler()