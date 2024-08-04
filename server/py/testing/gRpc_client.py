import grpc
import auth_pb2
import auth_pb2_grpc

def run():
    channel = grpc.insecure_channel('localhost:50051')
    stub = auth_pb2_grpc.AuthServiceStub(channel)
    response = stub.Authenticate(auth_pb2.AuthRequest(name='Dustin', password='drsneed'))
    print("Token received:", response.token)

if __name__ == '__main__':
    run()
