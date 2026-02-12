import azure.functions as func
import subprocess

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="")
def http_trigger1(req: func.HttpRequest) -> func.HttpResponse:

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        result = subprocess.check_output("echo "+name, shell=True, text=True)
        return func.HttpResponse(f"Hello, my name is {result}.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )