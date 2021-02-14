import boto3
from botocore.exceptions import ClientError
AWS_SES_REGION = "ap-southeast-1"
SENDER = "Uniqgift SFTP Server <notification.sftp.edenred.dev@uniqgift.com>"
RECIPIENT1 = "franck.boullier@uniqgift.com"
RECIPIENT2 = "franck@unee-t.com"
RECIPIENT3 = "franck.boullier@gmail.com"
SUBJECT = "A New File has been uploaded to the Data Ingestion Engine - TicketXpress"
	
def send_email(data):		
	print("Sending email...")
	BODY_TEXT = ("New File Uploaded:\r\n %s" % (str(data)))
	BODY_HTML = """<html>
	<head></head>
	<body>
	  <h1>A New File has been uploaded to the Data Ingestion Engine - TicketXpress</h1>
	  <p>New File Uploaded:</p>
	  <table border="1" cellpadding="10">
		<tbody>
			<tr>
				<td><b>Event Time</b></td>
				<td>%s</td>
			</tr>
			<tr>
				<td><b>File Name</b></td>
				<td>%s</td>
			</tr>
		</tbody>
		</table>
	</body>
	</html>
	""" % (data["eventTime"], data["s3"]["object"]["key"])            
	CHARSET = "UTF-8"
	client = boto3.client('ses',region_name=AWS_SES_REGION)
	try:
		response = client.send_email(
			Destination={
				'ToAddresses': [
					RECIPIENT1,
					RECIPIENT2,
					RECIPIENT3,
				],
			},
			Message={
				'Body': {
					'Html': {
						'Charset': CHARSET,
						'Data': BODY_HTML,
					},
					'Text': {
						'Charset': CHARSET,
						'Data': BODY_TEXT,
					},
				},
				'Subject': {
					'Charset': CHARSET,
					'Data': SUBJECT,
				},
			},
			Source=SENDER
		)
	except ClientError as e:
		print(e.response['Error']['Message'])
	else:
		print("Email sent! Message ID:"),
		print(response['MessageId'])

def lambda_handler(event, context):
	data = event["Records"][0]
	send_email(data)