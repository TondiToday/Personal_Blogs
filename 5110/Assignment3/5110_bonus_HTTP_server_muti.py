import socket
import threading


class ClientThread(threading.Thread):

    def __init__(self, client_address, client_socket):
        threading.Thread.__init__(self)
        self.csocket = client_socket
        print("New connection from client: ", client_address)

    def run(self):
        while True:
            try:
                # data received from client
                message_rec = self.csocket.recv(1024)
                filename = message_rec.split()[1]
                print('The file name you typed is: ', filename)

                f = open(filename[1:])
                outputdata = f.read()

                # Send one HTTP header line into socket
                self.csocket.send("HTTP/1.1 200 OK\r\n\r\n".encode())
                print("file found succeeded!")
                # Send the content of the requested file to the client
                for i in range(0, len(outputdata)):
                    self.csocket.send(outputdata[i].encode())
                self.csocket.send("\r\n".encode())
                self.csocket.close()

            except IOError:
                # Send response message for file not found
                self.csocket.send("HTTP/1.1 404 Not Found\r\n\r\n".encode())
                self.csocket.send("<html><head></head><body><h1>404 Not Found</h1></body></html>\r\n".encode())
                print("404(file) Not Found, please retry ...")
                # Close client socket
                self.csocket.close()


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
