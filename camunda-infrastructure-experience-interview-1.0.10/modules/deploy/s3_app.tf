# TODO: deploy the dummy S3 app in the kind cluster in a given namespace.
# Check 02-app-deploy/main.tf for all the details of the app.

# The app should be accessible from localhost via an Ingress on localhost:8086/s3-app
# The app is stateless. No TLS is required (plain HTTP)

# Hint: pay attention to ingressClassName value of the Ingress object for the solution to work
