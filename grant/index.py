
from crypt import methods
from bottle import route, run, template, request

@route('/grant/')
def do_grant():
    username = request.forms.get('username')
    password = request.forms.get('password')
    print(username)
    print(password)
    return template(" username={{username}} ,password={{password}}", username=username, password=password)


run(host='0.0.0.0', port=80,reloader=True)