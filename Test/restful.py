from flask import Flask, request
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)

# 示例资源类
class HelloWorld(Resource):
    def get(self):
        return {'message': 'Hello, World!'}

# 添加资源路由
api.add_resource(HelloWorld, '/hello')

if __name__ == '__main__':
    app.run(debug=True)
