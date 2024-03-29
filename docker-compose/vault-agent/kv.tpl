{{ with secret "secret/data/foo" -}}
<html>
    <head>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css" integrity="sha384-B0vP5xmATw1+K9KRQjQERJvTumQW0nPEzvF6L/Z6nronJ3oUOFUFpCjEUQouq2+l" crossorigin="anonymous">
    </head>
    <body>
        <div class="alert alert-success" role="alert">
        <h5 class="alert-heading">Secret path &#58; secret/data/foo, Policy &#58; nginx</h5>
            <li><strong>Timestamp</strong> &#58; {{ timestamp }}</li>
            <li><strong>foo</strong> &#58; {{ .Data.data.foo }}</li>
            <li><strong>pizza</strong> &#58; {{ .Data.data.pizza }}</li>
        </div>
    </body>
</html>
{{- end }}
