import socket
import threading


class ClientThread(threading.Thread):

    def __init__(self, client_address, client_socket):
        threading.Thread.__init__(self)
        self.csocket = client_socket
        print("New connection from client: ", client_address)

    def run(self):
        print("Connection from : ", addr)
        message = ''
        while True:
            message_rec = self.csocket.recv(1024)
            message = message_rec.decode()
            print("Message from client: '", message, "'")
            self.csocket.send(bytes(message, 'UTF-8'))


localhost = "127.0.0.1"
serverPort = 15000

serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
serverSocket.bind((localhost, serverPort))

print("Multi-thread Server Started")
print("Waiting for clients ...")

while True:
    serverSocket.listen(1)
    connectionSocket, addr = serverSocket.accept()
    new_thread = ClientThread(addr, connectionSocket)
    new_thread.start()
