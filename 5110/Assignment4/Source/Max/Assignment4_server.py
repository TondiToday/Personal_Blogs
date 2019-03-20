import socket
import threading
import csv
import itertools


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
                ack = message_rec.decode()
                if ack == 'HELLO':
                    print("ACK: '", ack, "'")
                    self.csocket.send(bytes("From server: "+ack, 'UTF-8'))
                    self.csocket.close()

                datatype = ack.split()[1]
                print('The data type is: ', datatype)

                filename = ack.split()[2]
                print('The data name is: ', filename)

                msgId = ack.split()[3]
                print('The message id is: ', msgId)

                msg_size = ack.split()[4]
                print('The message size is: ', msg_size)
                num_msg_size = int(msg_size)

                seqNum = ack.split()[5]
                print('The message sequence is: ', seqNum)
                num_seqNum = int(seqNum)

                # Send one HTTP header line into socket
                self.csocket.send("HTTP/1.1 200 OK\r\n\r\n".encode())
                print("file found succeeded!")

                with open(filename[1:]) as csvfile:
                    f = csv.reader(csvfile, delimiter=',')

                    for i in range(0, num_seqNum):

                        header = "From Server:" + datatype + ' ' + filename + ' ' + msgId + ' ' + msg_size + ' ' + str(
                            i + 1)
                        self.csocket.send(header.encode())
                        self.csocket.send("\r\n".encode())

                        for row in itertools.islice(f, i*num_msg_size, (i+1)*num_msg_size):
                            print("data_raw=========:", row)
                            data = ''.join(row)
                            self.csocket.send(data.encode())
                            self.csocket.send("\r\n".encode())

                self.csocket.send("\r\n".encode())
                self.csocket.close()

            except IOError:
                # Send response message for file not found
                self.csocket.send("HTTP/1.1 404 Not Found\r\n\r\n".encode())
                self.csocket.send("<html><head></head><body><h1>404 Not Found</h1></body></html>\r\n".encode())
                print("404(file) Not Found, please retry ...")
                # Close client socket
                self.csocket.close()


localhost = '192.168.1.110'
serverPort = 64001

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
