# HSE_DevOps_HW3

```
Outputs: 
db_instance_endpoint = "terraform-20201225155220338000000001.c0zujfrsbyz1.us-east-2.rds.amazonaws.com:3306"
dns_name = "elbexample-267774468.us-east-2.elb.amazonaws.com"
api_gateway_url = https://r637zmphaf.execute-api.us-east-2.amazonaws.com/dev/my-api
```
To test API a REST API was created using AWS Lambda Function.

The link to it:
```
https://k3gobxbe80.execute-api.us-east-2.amazonaws.com/my-api
```
You can find a generated API in API Gateway "mysimpleAPI"

To run a security scanner with ZAP Docker we need to follow their documentation (https://www.zaproxy.org/docs/docker/about/)
Run: 
```
docker run -t owasp/zap2docker-weekly zap-baseline.py -t http://$(ip -f inet -o addr show docker0 | awk '{print $4}' | cut -d '/' -f 1):8080 -r result.html

```

