from bottle import route, run, template

@route('/hello/<name>')


def index(name):
    code = '0000'
    msg = 'OK'
    lsg = 'xxxxxxxxxxxxx'
    return template('{"resultCode":"{{code}}","resultMsg":"{{msg}}","license":"{{lsg}}"}',code=code,msg=name,lsg=lsg)

run(host='localhost', port=80)